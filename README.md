# Summary
●	Collected and analyzed historical data to forecast particulate matter concentration (PM2.5) at Bundaran HI.
●	Identified, estimated, and diagnosed the ARIMA model using R.
●	Compared the forecasting accuracy of the ARIMA and Simple Moving Average (SMA) methods.
●	Both models demonstrated forecasting accuracy below 15%, indicating good predictive performance.

## Time Series Analysis

Perbandingan Model Peramalan Konsentrasi Partikulat (PM2,5) di Stasiun Bundaran HI Dengan Metode ARIMA dan Simple Moving Average (SMA)

Data:

<img width="546" alt="image" src="https://github.com/user-attachments/assets/516bd763-b937-4c30-b396-97e0411824f3" />


Metode ARIMA dan Simple Moving Average (SMA)

Langkah-langkah peramalan ARIMA:
1. EDA (Membagi data training dan testing, memeriksa kestasioneran data dalam mean dan varians)
2. Identifikasi Model
3. Estimasi Model
4. Diagnosis Model
5. Forecasting

Peramalan dengan SMA : perhitungan rata-rata dari sejumlah n periode ke belakang

Peramalan dengan ARIMA(0,1,1)

<img width="360" alt="image" src="https://github.com/user-attachments/assets/9f6fb2d5-aa56-401e-9551-8abaab415302" />

Nilai MAPE sebesar 0,1167 atau 11,67% 

Peramalan dengan SMA n = 3(kiri) dan n = 8(kanan)

<img width="542" alt="image" src="https://github.com/user-attachments/assets/69726202-676a-4734-87d3-fcec8c15431e" />

Nilai MAPE n = 3 sebesar 16,13% sedangkan dengan n = 8 sebesar 11,05%

Nilai MAPE dengan metode SMA dengan 8 periode lebih kecil dibandingkan nilai MAPE dengan metode ARIMA(0,1,1) sehingga metode SMA dengan 8 periode
memberikan performa yang lebih baik dalam hal keakuratan peramalan dibandingkan dengan model ARIMA(0,1,1). Tetapi kedua model sama-sama baik karena 
dimana lebih kecil dari 20% ini menunjukkan bahwa model peramalan baik.
