## Load package 'TSA' dan 'forecast'
#install.packages("TSA")
#install.packages("forecast")
#install.packages("readxl")   

library(readxl) 
library(TSA)
library(forecast)
library(tseries)

## Load data dan simpan sebagai objek spam
aqi <- readxl::read_excel("C:/Users/Chelsea/Downloads/data_AQI.xlsx")

## Ringkasan data Aqi
head(aqi)
dim(aqi)
n <- length(aqi$PM_duakomalima);n

## Bagi data menjadi dua bagian: data training dan testing (70-90%, 30%-10%)
## Data training untuk membangun model ARIMA
## Data testing untuk validasi model (Ini gw make kayak ibunya 2 minggu terakhir buat testing)
aqi.training <- aqi$PM_duakomalima[1:(n-11)]
aqi.testing <- aqi$PM_duakomalima[(n-10):n]

plot(aqi.training)
## Gunakan perintah ts() untuk merubah jumlah email spam harian menjadi data runtun waktu
aqi.ts <- ts(aqi.training)


## Buat plot runtun waktu dari data spam
plot(aqi.ts, ylab = "Konsentrasi Partikulat", xlab = "hari")

## Cek perlu tidaknya melakukan transformasi data untuk mengatasi non-stasioner dalam variansi
bc <- BoxCox.ar(aqi.ts)      # nah disini yg paling tinggi itu di 0.3
bc
trans.aqi.ts <- (aqi.ts)^-0.2  # makanya disini gw pangkat in 0.3
plot(trans.aqi.ts)

## Cek apakah data sudah stasioner dalam mean (uji adf atau uji kpss)
## Uji trend stokastik dengan uji KPSS (H0: stasioner vs H1: non-stasioner)
kpss.test(trans.aqi.ts, null="Level")  
#p-value hasilnya 0.02 < 0.05 Ho ditolak, artinya data tidak stasioner dan perlu differencing

## Plot diferensi ke-1 dari trans.spam.ts
aqi.ts.d1 <- diff(trans.aqi.ts, d = 1)
plot(aqi.ts.d1)  # nah pas sini chel itu kan harusnya ada di 2 sampe -2 tapi malah outline gitu sampe -4

# trus gw diferencing lagi eh jadi bagusan dari 2 sampe -2, harus 2 kali atau gmn deh menurut lo??
aqi.ts.d2 <- diff(trans.aqi.ts, d = 2)
plot(aqi.ts.d2)

##Uji stasioneritas dari diferensiasi ke-1 spam.ts.d1: (H0: stasioner vs H1: non-stasioner)
kpss.test(aqi.ts.d1)
#p-value (0.1) > 0.05, tidak signifikan, Ho diterima, tidak ada indikasi non-stasioner dalam mean



############# TAHAP 1: IDENTIFIKASI MODEL ######################################33
## Identifikasi Model dengan ACF dan PACF dari spam.ts.d1
par(mfrow=c(1,2))
acf(aqi.ts.d1)
pacf(aqi.ts.d1)
# kandidat model:MA(1)

## Identifikasi Model dengan EACF
eacf(aqi.ts.d1)
# kandidat model:MA(1)

## Identifikasi Model dengan kriteria informasi BIC
par(mfrow=c(1,1))
res <- armasubsets(y=aqi.ts.d1,nar=9,nma=9,y.name='test',ar.method='ols')
plot(res)
# kandidat model: MA(1)

### KESIMPULAN --> p =0, q =1, d =1  (ARIMA(0,1,1)=IMA(1, 1))

############# TAHAP 2: ESTIMASI MODEL

## Estimasi parameter model dari trans.spam.ts sebagai proses ARMA dengan q=1 dan d=1
aqi.arima.011 <- stats::arima(trans.aqi.ts,order=c(0,1,1))
aqi.arima.011

# estimasi model: zt = et -0.8665et-1


#Gunakan perintah auto.arima() dari package 'forecast' - Secara otomatis untuk menentukan order p, q, & d sekaligus memberikan estimasi parameter model
aqi.auto <- auto.arima(trans.aqi.ts)
aqi.auto


############# TAHAP 3: DIAGNOSIS MODEL

residual <- rstandard(aqi.arima.011)


## Plot residual
plot(residual)


## Cek normalitas dengan histogram dan QQ plot
par(mfrow=c(1,2))
hist(residual)
qqnorm(residual)
qqline(residual)

## Uji normalitas
shapiro.test(residual)
jarque.bera.test(residual)
# p-value shapiro tes > 0.05, tidak signifikan, Ho diterima, residual normal
# p-value jarque bera tes < 0.05, signifikan, Ho ditolak, residual normal

## Cek autokorelasi: individu
par(mfrow=c(1,1))
acf(residual)

## Uji autokorelasi dengan ljung.box: serentak
Box.test(residual,lag=15,type = c("Ljung-Box"))
# p-value(0.8983) > 0.05, tidak signifikan, Ho diterima, residual independent


## Diagnosis dengan overfitting 
aqi.arima.011
aqi.arima.012 <- stats::arima(trans.aqi.ts,order=c(0,1,2)) 
aqi.arima.012
# parameter tambahan ma2 tidak signifikan & parameter ma1 tidak berubah drastis

#----Apakah residual menunjukkan white noise?

############# TAHAP 4: FORECASTING (PRAKIRAAN) / MENGEVALUASI AKURASI MODEL

## Plot data sebenarnya (yt) dan hasil prediksi model ARIMA(1,1,0)
actual <- aqi.ts

## perintah fitted() digunakan untuk mengeluarkan hasil prediksi yt
fitted(aqi.arima.011)
pred <- fitted(aqi.arima.011)^(-10/2) # transformasi balik ke data aktual
par(mfrow=c(1,1))
plot(actual, ylab = "yt")
lines(pred, col = "red", lwd = 2)
legend("topleft", c("aktual", "prediksi"), col=c(1,2), lty = 1)


## Gunakan perintah forecast() untuk memvalidasi model
## dengan cara memprediksi jumlah email spam 14 hari kedepan
aqi.forecast <- forecast(aqi.arima.011, 11)
aqi.forecast
plot(aqi.forecast)
prediksi <- aqi.forecast$mean # simpan hasil prediksi 11 hari kedepan ke objek prediksi (prediksi dalam bentuk akar)
prediksi2 <- prediksi^(-10/2) # transformasi hasil prediksi ke dalam skala data asli


## data testing
aqi.testing <- aqi$PM_duakomalima[(n-10):n]


## plot data sebenarnya (yt) dengan hasil peramalan
plot(aqi.testing,type='o', ylab = "Konsentrasi Partikulat", xlab = "waktu (hari)")
lines(ts(prediksi2),col='red',type='o')
legend("topright", c("aktual", "prediksi"), col=c(1,2), lty = 1)


## Bandingkan data testing dengan hasil prediksi
## Cara 1: hitung MSE (Mean Square Error)
mean((aqi.testing-prediksi2)^2) #MSE 

## Cara 2: hitung MAPE (Mean Absolute Percentage Error)
mean(abs((aqi.testing - prediksi2)/aqi.testing)) #MAPE
#MAPE = 68% (model prediksi yang baik < 20%)

##### Analisis runtun waktu dengan metode SMA
library(TTR)
#untuk n=3
aqi_sma1<-SMA(aqi.ts, n = 3)
plot(aqi_sma1)
lines(aqi_sma1, col="blue")
lines(aqi.ts, col="red")

prediksi1<-forecast(aqi_sma1, h=11)
autoplot(prediksi1)
lines(aqi.ts, col='red')
prediksi_mean<-prediksi1$mean
mean((aqi.testing-prediksi_mean)^2) #MSE 
mean(abs((aqi.testing - prediksi_mean)/aqi.testing)) #MAPE

#untuk n=8
aqi_sma2<-SMA(aqi.ts, n =8)
plot(aqi_sma2)
lines(aqi_sma2, col="blue")
lines(aqi.ts, col="red")

prediksi2<-forecast(aqi_sma2, h=11)
autoplot(prediksi2)
prediksi_mean<-prediksi2$mean
mean((aqi.testing-prediksi_mean)^2) #MSE 
mean(abs((aqi.testing - prediksi_mean)/aqi.testing)) #MAPE












