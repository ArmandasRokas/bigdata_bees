## Data beskrivelse

- der er så mange variable, men det blev brugt kun disse: 
- Beskrive alle variabler
- Hvor mange observationer, hvor mange timestamps der mangler
- Vægt delta. Differencele. 
- graffer
- 
- I started har jeg valgt til at bruge data fra ét år. Dvs. 01 SEP 2019 - 01 SEP 2020  





- Indtil videre fokusere jeg kun på vægt, da det er mest interresent. 

### Grafen af vægten 

![](/home/arm/Projects/bigdata/bistader/images/plot_time_weight_from_2019_06_06.png)



## Data rensing

- Problem at der skulle fjernes alle manual indgreb på bistadet, da det bias dataset. Manual indgreb kunne være at biavlen indsætte mad til bierer om vinteren. Eller påsætte en ny magasin. 
- Lave en plot med en eksampel. 

**Noise:**

- Missing timestamps
- Manual indgreb 
- Regn
- .... Spørge Frederik







### Manualt indgreb

-  Første problem var der manglede nogen timestamp. De er ret interresent fordi det hænger sammen nogen gange med manual ingreb. Dvs Målet var at oprette det missing timestamps med NA vægt osv., så man ku forstå problemets opfang



```R
# Return weight deltas after missing timestamps
> hive_data[which(hive_data[,"timestamp_delta"] > 7), c("hive_observation_time_local", "weight_delta")]
      hive_observation_time_local weight_delta
769           2020-05-03 16:25:01        -2.78
1578          2020-05-06 12:00:41         6.90
3622          2020-05-13 15:15:01         0.00
6810          2020-05-24 17:05:01        -0.23
7900          2020-05-28 12:25:01         3.49
9025          2020-06-01 11:15:01         0.10
11335         2020-06-09 12:55:01        -0.15
12795         2020-06-14 15:05:01        -0.34
15156         2020-06-22 20:05:01         0.07
15668         2020-06-24 15:10:01         0.12
15671         2020-06-24 15:45:15        -0.09
16563         2020-06-27 18:15:01         3.89
17094         2020-06-29 14:50:01        -0.15
17341         2020-06-30 11:30:01         0.21
17620         2020-07-01 13:30:01       -10.38
17851         2020-07-02 08:50:01         0.12
19681         2020-07-08 17:45:02         0.21
19682         2020-07-08 18:05:35        -0.27
21403         2020-07-14 17:45:01         0.04
21924         2020-07-16 14:10:01        -0.76
22060         2020-07-17 01:35:01        -0.01
22267         2020-07-17 19:20:01         0.08
22490         2020-07-18 14:00:01         0.03
22785         2020-07-19 14:45:01        -0.03
22786         2020-07-19 15:00:01        -0.02
23083         2020-07-20 15:50:01        -0.02
24513         2020-07-25 15:05:02         0.39
25132         2020-07-27 18:55:01        -0.12
28558         2020-08-08 17:15:55         0.21
29937         2020-08-13 12:50:01        -5.90
30821         2020-08-16 15:00:01         0.16
32396         2020-08-22 02:20:01         0.00
32633         2020-08-22 22:10:01         0.00
32705         2020-08-23 04:15:01         0.01
33937         2020-08-27 13:05:02       -20.61
33938         2020-08-27 13:15:56         2.74
33948         2020-08-27 14:15:01         5.08
34493         2020-08-29 12:25:01        -0.96
```

![](/home/arm/Projects/bigdata/bistader/images/manual_intervention_2020_05_28.png)

![](/home/arm/Projects/bigdata/bistader/images/time_weight_2020_summer.png)



## Lægge vejr data sammen

- En anden udfordring at tilføje mm til data fra den anden kilde. Så man har også om det regnet eller nej. 



### Correlation

- Dokumenterer fundet korrelation og forklar at Frederik sagde at det gives ikke mening og i parksis vil det ikke give mening linear regration. Hvad med om virteren? Hvor den stille og roligt gå ned i vægten, fordi de spiser mad, og sige hvornår der ikke noget mad mere,