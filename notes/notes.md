### Databehandling

- Hvis jeg har lyst til at bruge hele periode, så det er muligt at fjerne værdier f.eks. < 10 og > 80 ligesom p[ eksampel på siden 78: `leadership$age[leadership$age == 99] <- NA`  .På den måde undgå man at plotte dataen. 



### Correlation between weight and temperature

- cor between weight and temp is only 0.01, but if I select only midnight data?

- cor 0.65 using NASA data, midnights. Statistically significant cor.  
- Maybe try with pounds. maybe more clear coefficient

- **Cross-correlation** is the comparison of two different time series to detect if there is a correlation between metrics with the same maximum and minimum values. For example: “Are two audio signals in phase?

- **Auto-correlation** is the comparison of a time series with itself at a different time. It aims, for example, to detect repeating patterns or seasonality. For example: “Is there weekly seasonality on a server website?” “Does the current week’s data highly correlate with that of the previous week?”
- http://r-statistics.co/Time-Series-Analysis-With-R.html
- https://www.quantstart.com/articles/Serial-Correlation-in-Time-Series-Analysis/

### Time series weight

- Er min data egnet til timeseries analysen?
- **Formål**: finde ud af hvornår der er manual indgreb på stedet for at udligne grafen, så man kan kun se bienes bevægelse. ̈́
  - Udligne grafen så meget som muligt. Regn, manual indgreb. Så man kan kun se biernes bevægelse. Tag billeder af to grafer. Før og efter
  - Et det nok at lave data behandling til dette kursus eller skal der også være predictions? 
  - Tage en lille del af interval. F.ek.s kun sommer. 
  - definere automatisk Threshold (kg/hr ??) ud fra dataset. Forudsige fremtidens threshold. Nuværende hardcoded på Hivetool er 13,6kg. Er det altid 13,6kg ? Kan der være mindre? Kan det optimeres på grund af sæsoner? 
    - Brugerdefineret Threshold. Ikke bruger koeficient, da det kan blive forvirrende i længten. 
    - https://robjhyndman.com/hyndsight/anomalous/
  - finde datapunkter, hvor Threshold blev overskrevet
    - https://otexts.com/fpp2/missing-outliers.html
    - Quartiles values are too small for removing outliers. 
  - udligne det i dataset
  - There is too little change in bi daily rutine to define max and it is not always they fly out. I should look at daily midmights values to define Max instead. 
- Try to find out how much change can it be every day normally in the summer. 
- Find days delta from not NASA dataset with NASA. and try to plot. 

  - https://stackoverflow.com/questions/21667262/how-to-find-difference-between-values-in-two-rows-in-an-r-dataframe-using-dplyr
  - and 
- Hvordan finder jeg midnat data?



```
1. Find delta values
2. Remove outliers
3. Define a start value (maybe median of the orginal dataset or the value of first index)
4. Add calculated deltas without outliers to the defined start values
```

- https://www.rdocumentation.org/packages/schoRsch/versions/1.7/topics/outlier Remove outliers function. `upper.limit` an optional numerical specifying the absolute upper limit defining outliers. 



### Snak med Tomasz

- https://beep.nl/home-english
- Knytte sammen vejrdata og bestade data. Når det regner, så bliver bistade tungere. Så der skal minuseres fra bistade vægt. 
- Prediction at bifamilie har det dårligt. Hvis de henter ikke nok honing. 

### Snak med John

- Begynde at beskrive data, lave forskellig diagrammer. 
- Måske sammenligne fra årtal til årtal
- down sampling
- Undersøge på net om der er nogen lavet statistical modelling på biene



