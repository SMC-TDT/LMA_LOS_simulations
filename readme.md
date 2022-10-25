# LMA Line Of Sight simulations
Aquest programari en llenguatge R estima, a partir d'un model digital de terreny (DEM), l'altura mínima de visibilitat d'una estació LMA (en unes coordenades donades per l'usuari) en cada punt del territori català. A més, a partir d'una llista d'estacions LMA, permet generar un mapa compost de quantes d'aquestes estacions tenen visibilitat per sobre d'una altura donada en cada punt del territori. 

## Estructura de carpetes:

La carpeta LMA_LOS_simulations ha de contenir com a mínim les següents 2 carpetes (les carpetes de sortida es generaran automàticament):
- **DATA/**: conté els arxius de dades de les estacions LMA (**LMA_coords.txt** i **LMA_data.txt**) i tres carpetes: **CONTORN/** (shapefile per recortar les dades al territori de Catalunya), **DEM/** (Models Digitals d'Elevació de la regió) i **SHP/** (*shapefiles* de la regió). 
- **scripts/**: conté els scripts necessaris per a la configuració i execució de l’algorisme (**LMA_LOS_simulations.R**, **LMA_LOS_funs.R** i **LMA_LOS_sets.R**).

## Llibreries R:
- *raster*
- *gdal*
- *plyr*: agrupar i resumir dades
- *data.table*: manipular taules de dades
- *akima*: interpolar dades
- *maptools*: llegir shapefiles

## 1. Simulacions individuals (*LMA_LOS_simulations.R*)

L'algorisme calcula les coordenades polars (r, az) de la LOS (Line Of Sight, línia de visibilitat) del sensor i les interpola a la quadrícula del DEM (x, y). A partir de l'altura del DEM i l'altura del sensor LMA sobre el nivell del mar (també estimada en la localització del sensor a partir del DEM), calcula l'angle LOS respecte a l'horitzó del sensor en cada punt de la quadrícula. Després, calcula l'angle LOS màxim acumulat al llarg de la LOS i, d'aquí, deriva l'altura mínima de visibilitat en cada punt. Finalment, genera un arxiu Geotiff i un mapa en format png amb els resultats.

### Input (usuari): 

/path_wrk/DATA/LMA_coords.txt (arxiu amb l'ID, nom i coordenades UTM de les estacions LMA)

### Output: 

/path_wrk/INDV_TIF/LOS_lma_ID#_RXXXkm.tif (arxiu Geotif)

/path_wrk/INDV_PNG/LOS_lma_ID#_RXXXkm.png (figura png)

### INSTRUCCIONS D'ÚS

1. **/path_wrk/DATA/LMA_coords.txt**: Introduïu ID, Nom i coordenades UTM (x, y) de les estacions LMA per les quals vulgueu fer la simulació (ometeu aquest punt si les estacions ja estan enregistrades a l'arxiu).

2. **/path_wrk/scripts/LMA_LOS_simulations.R**: en l'apartat SETTINGS al començament de l'script, indiqueu els IDs de les estacions que voleu simular (*$lma_ID*) i modifiqueu, si fos necessari, la variable del directori de treball (*$path_wrk*).

3. **/path_wrk/scripts/LMA_LOS_sets.R** (opcional): podeu modificar altres paràmetres, com ara: fitxers d'entrada, directoris d'entrada i sortida, límits i resolució de la LOS en coordenades polars i del raster de sortida i escales de colors de la figura de sortida. Tanmateix, per garantir el funcionament del programari, es recomana no modificar aquests paràmetres, excepte si teniu molt clar el què feu ;).

4. Executar l'script principal: `$ Rscript /path_wrk/scripts/LMA_LOS_simulations.R`


<img src="https://github.com/SMC-TDT/LMA_LOS_simulations/blob/main/LMA_LOS_simulation.png" width="800" height="400">

## 2. Composició d'estacions (*LMA_LOS_composite.R*)

D'una llista d'estacions LMA escollides per l'usuari (per les quals les simulacions individuals de la LOS ja han estat generades), l'algorisme calcula en cada punt del territori quantes d'aquestes estacions tenen una altura mínima de visibilitat menor o igual que l'altura de referència indicada per l'usuari. Genera dos mapes amb aquesta informació; un general amb la cobertura de tota l'extensió del DEM i un altre amb la cobertura de només el territori català.

### Input (auto): 

/path_wrk/INDV_TIF/LOS_lma_ID#_RXXXkm.tif (arxius Geotif dels mapes de visibilitat de les estacions; output del procés *LMA_LOS_simulations.R*)

### Output: 

/path_wrk/CMP_TIF/NUM_lma_HXXXXm_RXXXkm_cmpname.tif i /path_wrk/CMP_PNG/NUM_lma_HXXXXm_RXXXkm_cmpname_crop.tif (arxius Geotif)

/path_wrk/CMP_TIF/NUM_lma_HXXXXm_RXXXkm_cmpname.png i /path_wrk/CMP_PNG/NUM_lma_HXXXXm_RXXXkm_cmpname_crop.png (figures png)

### INSTRUCCIONS D'ÚS

1. **/path_wrk/scripts/LMA_SIM_sets.R**: en la variable *$cmp_lst* de l'apartat MAIN SETTINGS, afegiu el nom de la composta i la llista de les estacions LMA que n'ha d'incloure (ometeu aquest punt si la composta ja està enregistrada en la variable).

2. **/path_wrk/scripts/LMA_LOS_composite.R**: en l'apartat SETTINGS al començament de l'script, indiqueu els noms de les compostes que voleu generar (*$cmp_names*), les altures de referència (*$heights_ref*) i modifiqueu, si fos necessari, el directori de treball (*$path_wrk*).

3. **/path_wrk/scripts/LMA_LOS_sets.R** (opcional): podeu modificar altres paràmetres, com ara: directoris d'entrada i sortida, arxius d'entrada, límits i resolució del raster de sortida i escales de colors de la figura de sortida.

4. Executar l'script principal: `$ Rscript /path_wrk/scripts/LMA_LOS_composite.R`
