# LMA Line Of Sight simulations
Aquest programari en llenguatge R estima, a partir d'un model digital de terreny (DEM), l'altura mínima de visibilitat d'una estació LMA (en unes coordenades donades per l'usuari) en cada punt del territori català.

## DESCRIPCIÓ
L'algorisme calcula les coordenades polars (r, az) de la LOS del sensor i les interpola a la quadrícula del DEM (x, y). A partir de l'altura del DEM i l'altura del sensor LMA sobre el nivell del mar (també estimada en la localització del sensor a partir del DEM), calcula l'angle LOS respecte a l'horitzó del sensor en cada punt de la quadrícula. Després, calcula l'angle LOS màxim acumulat al llarg de la LOS i, d'aquí, deriva l'altura mínima de visibilitat en cada punt. Finalment, genera un arxiu Geotiff i un mapa en format png amb els resultats.

INPUT USUARI: /work_path/DATA/LMA_coords.txt (arxiu amb l'ID, nom i coordenades UTM de les estacions LMA)
OUTPUt: /work_path/TIF/LOS_lma_ID#.tif (arxiu Geotif) i /work_path/FIG/LOS_LMA_ID#.png (figura png)

### Estructura de carpetes:

La carpeta LMA_LOS_simulations ha de contenir com a mínim les següents 2 carpetes (les 2 carpetes de sortida es generaran automàticament):
- DATA: conté 
- scripts: conté els scripts necessaris per a la configuració i execució de l’algorisme (*LMA_LOS_simulations.R*, *LMA_sim_funs.R* i *LMA_SIM_sets.R*).

### Llibreries R:
- raster
- gdal
- plyr: agrupar i resumir dades
- data.table: manipular taules de dades
- akima: interpolar dades
- maptools: llegir shapefiles

## INSTRUCCIONS D'ÚS

1. Introduïu ID, Nom i coordenades UTM (x, y) de les estacions LMA per les quals vulgueu fer la simulació en l'arxiu d'entrada */work_path/DATA/LMA_coords.txt* (ometeu aquest punt si les estacions ja estan enregistrades a l'arxiu).

2. Obriu el programa principal *LMA_LOS_simulations.R* i, en l'apartat SETTINGS al començament de l'script, indiqueu els IDs de les estacions que voleu simular (*lma_ID*) i modifiqueu, si fos necessari, el directori de treball (*path_work*).

3. (opcional) Podeu modificar paràmetres addicionals com ara fitxers d'entrada, directoris de sortida, límits i resolució de la LOS en coordenades polars i del raster de sortida i escales de colors de la figura de sortida, en l'script *LMA_SIM_sets.R*. Tanmateix, per garantir el funcionament del programari, es recomana no modificar aquests paràmetres, excepte si teniu molt clar el què feu ;).

4. Executar l'script principal. En cas que ho feu des de la terminal:
  
  `$ Rscript /work_path/scripts/LMA_LOS_simulations.R`
