
#----Preparations-----

#download bio-formats jar (Bio-Formats Package) at https://www.openmicroscopy.org/bio-formats/downloads/

library(rJava)
library(tools)
library(magick)
library(jpeg)

# --- Settings ---
# Original folder (input)
input_dir <- ""

# Base output folder
base_output_dir <- ""

# Get the name of the input folder (e.g., "Zeiss images")
input_folder_name <- basename(input_dir)

# Create output folder with the name
output_dir <- file.path(base_output_dir, paste0(input_folder_name, "_tiff_files"))

# Create the folder if it doesn't exist
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

cat("Output directory:", output_dir, "\n")


# Bio-Formats JAR
bf_jar <- "C:/Users/Z624192/OneDrive - Radboudumc/Java program/bioformats_package.jar" #its location
.jinit() #Purpose: Converts an R number to a Java primitive int.
.jaddClassPath(bf_jar)
ImageReader <- J("loci.formats.ImageReader")

# --- Get all CZI files in folder ---
czi_files <- list.files(input_dir, pattern = "\\.czi$", full.names = TRUE)

# --- Process each file ---
for (czi_file in czi_files) {
  
  cat("Processing:", basename(czi_file), "\n")
  
  # Initialize reader
  reader <- new(ImageReader)
  reader$setId(czi_file)
  .jcall(reader, "V", "setSeries", as.integer(0))  # first series (usually 0)
  
  # Image dimensions
  width <- reader$getSizeX()
  height <- reader$getSizeY()
  
  # Read first plane (usually 0)
  plane <- .jcall(reader, "[B", "openBytes", 0L)
  img_matrix <- matrix(as.integer(plane), nrow = height, ncol = width, byrow = TRUE) # Convert Java byte array to R numeric vector
  
  
  # Normalize
  img_norm <- img_matrix / max(img_matrix)
  
  # Convert to magick
  img <- image_read(as.raster(img_norm))
  img <- image_convert(img, colorspace = "gray", format = "tiff")
  
  
  # Save tiff to output folder
  base_name <- file_path_sans_ext(basename(czi_file))
  tiff_file <- file.path(output_dir, paste0(base_name, ".tiff"))
  image_write(img, path = tiff_file, format = "tiff")
  
  cat("Saved:", tiff_file, "\n\n")
}

cat("All files processed!\n")

# to see the image info
image_info(image_read(tiff_file))


