---
title: "Raport ZED"
author: "Patryk W�glarz"
date: "11 luty, 2018"
output:
  html_document:
    keep_md: yes
---

## Wst�p

W raporcie zawarto wyliczenia modelu regresyjnego prognozuj�cego mocy urz�dzenia fotowoltaicznego.
Model mo�na z ma�ym b��dem upro�ci� do nast�puj�cego r�wnania:

P = 0.16 + naslonecznienie * 0.82 + wspolczynnikNaslonecznieniaPVGIS * 0.36

## 1. Wykorzystane biblioteki

W trakcie pracy wykorzystano pakiety wy��cznie pakiety wymagane do uruchomienia R Markdown Document oraz Shiny.

## 2. Wczytanie danych i powtarzalno�� wynik�w

Przed ka�dorazowym wybraniem zbioru danych do treningu i weryfikacji ustawiany jest seed liczb losowych. Stanowi to pewny spos�b na powtarzalno�� wynik�w analizy.


```r
set.seed(666)
```

## 3. Wczytywanie danych

Dane s� wczytywane z pliku csv dostarczonego z wymaganiami projektu. Nast�pnie zamieniana jest kolejno�� kolumn w celu �atwiejszego wykorzystania funkcji lm tworz�cej model liniowy. Funkcja lm domy�lnie wybiera pierwsz� kolumn� jako zmienn� zale�n�. Nazwy wykorzystywanych kolumn zostaj� podmienione.


```r
    dat = read.csv("elektrownie.csv", header = TRUE)
    data <- dat[c(51,1:50)]

    colnames_tmp <- colnames(data)
    colnames_tmp[3] <- "idMiejsca"
    colnames_tmp[4] <- "idModelu"
    colnames_tmp[5] <- "idMarki"
    colnames_tmp[8] <- "wiekWMiesiacach"
    colnames_tmp[9] <- "rok"
    colnames_tmp[10] <- "dzien"
    colnames_tmp[11] <- "moment"
    colnames_tmp[13] <- "temperaturaOtoczenia"
    colnames_tmp[14] <- "naslonecznienie"
    colnames_tmp[15] <- "cisnienie"
    colnames_tmp[16] <- "predkoscWiatur"
    colnames_tmp[17] <- "wilgotnosc"
    colnames_tmp[19] <- "punktRosy"
    colnames_tmp[20] <- "lozyskoWiatrowe"
    colnames_tmp[21] <- "zachmurzenie"
    
    colnames_tmp[22] <- "temperaturaI"
    colnames_tmp[23] <- "naslonecznienieI"
    colnames_tmp[24] <- "cisnienieI"
    colnames_tmp[25] <- "predkoscWiatuIr"
    colnames_tmp[26] <- "wilgotnoscI"
    colnames_tmp[27] <- "punktRosyI"
    colnames_tmp[28] <- "lozyskoWiatroweI"
    colnames_tmp[29] <- "zachmurzenieI"
    
    colnames_tmp[30] <- "odleglosc"
    colnames_tmp[31] <- "wysokosc"
    colnames_tmp[32] <- "szerkoscGeograficzna"
    colnames_tmp[33] <- "wysokoscI"
    colnames_tmp[34] <- "szerkoscGeograficznaI"
    
    colnames_tmp[50] <- "wspolczynnikNaslonecznieniaPVGIS"
    colnames_tmp[51] <- "wspolczynnikNaslonecznieniaPVGISI"
    colnames(data) <- colnames_tmp
    
    # uzycie tylko danych liniowych
    data <- data[c(1,8:11,13:34,50:51)]
#...

    indexes <- function(){
      set.seed(666);
      sample(1:nrow(data), size=0.8*nrow(data));
    }
    
    test <- function() {
      data[indexes(),];
    }
    
    train <- function() {
      data[-indexes(),]
    }
```

## 4. Brakuj�ce dane

Z racji nie posiadania wiedzy o mo�liwych warto�ciach parametr�w dane, kt�re wykorzystujemy do oblicze� uznajemy za czyste. U�ywamy do oblicze� tylko kolumn, co do kt�rych mamy uzasadnione podejrzenie, �e s� ci�g�e. Wszystkie zmienne, co do kt�rych istnieje w�tpliwo�� na rzecz danych kategorycznych pomijamy.


```r
#data <- data[c(1,8:11,13:34)]
```

## 5. Rozmiar i statystyki

Rozmiar pliku csv to 66,3MB. U�yto jednak tylko po�ow� kolumn, reszt� warto�ci pomini�to ze wzgl�du braku pewno�ci co do ich ci�g�o�ci.

## 6. Warto�ci atrybut�w

U�ywamy do oblicze� tylko kolumn, co do kt�rych mamy uzasadnione podejrzenie, �e s� ci�g�e. Wszystkie zmienne, co do kt�rych istnieje w�tpliwo�� na rzecz danych kategorycznych pomijamy.


```r
summary(data)
```

## 7. Korelacja mi�dzy moc� a reszt� wsp�czynnik�w


```r
    correlation <- function() {
      #temporary = c(1:51)
      temporary <- c(1:29);
      for (i in 2:29) {
        temporary[i] <- cor(train()[[i]],train()[[1]]);
        if (temporary[i] < 0) {
          temporary[i] <- -temporary[i];
        }
      }
      temporary[1] <- -1;
      
      temporary;
    }

    bad <- function() {
      min <- 0;
      correlation() > min;
    }
    
    good <- function() {
      #min=input$decimal;
      min <- 0.6;
      correlation() > min;
    }
    
    goodAnd1 <- function() {
      temporary <- good();
      temporary[1] <- T;
      temporary;
    }
    
    model <- function() {
      temporary <- lm(train()[goodAnd1()])
      temporary
    }
    
      #Barplot ze wszystkimi wartosciami
      barplot(correlation()[bad()],names.arg = colnames(train()[bad()]),
              main="KORELACJA",
              ylab="Korelacja do mocy",
              xlab="Wspolczynnik");
```

![](document_files/figure-html/korelacja-1.png)<!-- -->

```r
      #Barplot z wartosciami wykorzystanymi w modelu
      barplot(correlation()[good()],names.arg = colnames(train()[good()]),
              main="KORELACJA",
              ylab="Korelacja do mocy",
              xlab="Wspolczynnik");
```

![](document_files/figure-html/korelacja-2.png)<!-- -->

## 8. Interaktywna moc w czasie i przestrzeni


```r
      #TO DO
```

## 9. Model


```r
      cof <- model()$coefficients;
      
      names <- names(model()$coefficients);
      names[1] = 'bias';
      
      hprint <- matrix("",model()$rank,2);
      for (i in 1:model()$rank) {
        hprint[i,2] <- cof[i];
        hprint[i,1] <- names[i];
      }
      
      as.data.frame(hprint,optional = T)
```

Blad modelu jest nast�puj�cy:


```r
      error_vec <- unname(predict.lm(model(),test())) - test()[,1];
      error_vec <- error_vec * error_vec;
      mean(error_vec)
```

## 10. Analiza modelu

Model mo�e korzysta� z 2 warto�ci - pomiaru nas�onecznienia oraz wsp�czynnika PVGIS. Wszelkie inne pomiary mo�emy pomin�� generuj�c bardzo ma�y dodatkowy b��d.
Najdok�adniejszy model uzyskujemy wykorzystuj�c wysztkie warto�ci, jednak czas jego budowania oraz wykorzystania jest znacznie d�u�szy, a wyniki zbli�one. St�d jego przydatno�� jest znikoma.