O objetivo desse projeto é realizar o download de imagens Sentinel-1 GRD (Ground Range Detected) do modo de imageamento IW (Interferometric Wide) e em seguida realizar o pré-processamento das imagens baixadas para gerar as bandas de polarização VH e VV em unidade de potência linear projetadas para gamma0. Depois disso, as bandas VV e VH são usadas para calcular os índices de vegetação de dupla polarização desenvolvidos ou adaptados para imagens Sentinel-1.

### Script 01: geographical search and batch download of SAR data in the Alaska Satellite Facility (ASF) dataset:

![Pipeline_framework-Script_01](https://user-images.githubusercontent.com/52005057/184925308-32fbb954-22cb-41f6-b392-1be074eca7ea.png)

### Script 02: reading and visualizing a single product band:

![Pipeline_framework-Script_02](https://user-images.githubusercontent.com/52005057/184925460-77f836ca-bff0-4014-a025-773a57fc8862.png)

### Script 03: preprocessing of Sentinel-1 SAR products (from removing thermal noise to orthorectification):

![Pipeline_framework-Script_03](https://user-images.githubusercontent.com/52005057/184925506-2235258b-a2b9-4a51-b49d-b6f498e1a3ff.png)

### Script 04: subsetting scenes using an polygon area of interest:

![Pipeline_framework-Script_04](https://user-images.githubusercontent.com/52005057/184925536-4fae038a-588d-4687-94d8-65882407b7f8.png)

### Script 05: computing SAR dual-pol vegetation indices:

![Pipeline_framework-Script_05](https://user-images.githubusercontent.com/52005057/184925769-8e3fc9c6-15b4-42bb-8bb8-65cb669a2b34.png)

### Script 06: sampling raster products using R:

![Pipeline_framework-Script_06](https://user-images.githubusercontent.com/52005057/184925805-9008c05e-25a5-462c-945d-51c30c3fc5ec.png)
