
OpenLongData <- S7::new_class(
  name = "OpenLongData",
  package = "OpenLong",
  properties = list(
    filepath     = S7::class_character,
    baseline     = S7::class_data.frame,
    longitudinal = S7::class_data.frame,
    components   = S7::class_list,
    loaded       = S7::new_property(S7::class_logical, default = FALSE),
    excluded     = S7::new_property(S7::class_logical, default = FALSE),
    cleaned      = S7::new_property(S7::class_logical, default = FALSE),
    derived      = S7::new_property(S7::class_logical, default = FALSE)
  ),
  validator = function(self) {

    if (length(self@filepath) != 1) {
      "@filepath must be a single character value"
    }
  }
)

# virtual functions that will be defined in derived classes ----

# each of these functions needs to be defined in all child classes
read_baseline     <- S7::new_generic("read_baseline", "x")
read_longitudinal <- S7::new_generic("read_longitudinal", "x")

derive_baseline     <- S7::new_generic("derive_baseline", "x")
derive_longitudinal <- S7::new_generic("derive_longitudinal", "x")

clean_baseline     <- S7::new_generic("clean_baseline", "x")
clean_longitudinal <- S7::new_generic("clean_longitudinal", "x")

# Generics for all open long data objects ----

# each of these functions will be inherited by all child classes

data_load <- S7::new_generic("data_load", "x")

S7::method(data_load, OpenLongData) <- function(x){
  x@components$baseline <- read_baseline(x)
  x@components$longitudinal <- read_longitudinal(x)
  x@loaded <- TRUE
  x
}

data_derive <- S7::new_generic("data_derive", "x")

S7::method(data_derive, OpenLongData) <- function(x){
  x@baseline <- derive_baseline(x)
  x@longitudinal <- derive_longitudinal(x)
  x@derived <- TRUE
  x
}

data_clean <- S7::new_generic("data_clean", "x")

S7::method(data_clean, OpenLongData) <- function(x){
  x@baseline <- clean_baseline(x)
  x@longitudinal <- clean_longitudinal(x)
  x@cleaned <- TRUE
  x
}

get_components <- S7::new_generic("get_components", "x")

S7::method(get_components, OpenLongData) <- function(x){
  x@components
}

as_list <- S7::new_generic("as_list", "x")

S7::method(as_list, OpenLongData) <- function(x){
  list(baseline = x@baseline, longitudinal = x@longitudinal)
}

as_longitudinal <- S7::new_generic("as_longitudinal", "x")

S7::method(as_longitudinal, OpenLongData) <- function(x){
  x@longitudinal
}

as_baseline <- S7::new_generic("as_baseline", "x")

S7::method(as_baseline, OpenLongData) <- function(x){
  x@baseline
}


# Child classes ----

# keeping these in the same file is helpful - it prevents errors that
# may occur when separate files are not sourced in the right order.
OpenLongMesa <- S7::new_class(
  name = "OpenLongMesa",
  package = 'OpenLong',
  parent = OpenLongData,
  validator = function(self) {

    if(length(self@filepath) == 1){

      if("Primary" %nin% list.files(self@filepath)){
        paste0(
          "Primary directory not found in filepath: \'", self@filepath, "\'.",
          "\n- filepath should be the location of",
          " BioLincc MESA data on your device."
        )
      }

    }

  }
)

S7::method(read_baseline, OpenLongMesa) <- function(x){
  input_mesa1 <- readr::read_csv(file = file.path(x@filepath,
                                                  "Primary",
                                                  "Exam1",
                                                  "Data",
                                                  "mesae1dres20220813.csv"),
                                 show_col_types = FALSE,
                                 guess_max = Inf)

  list(input_mesa1 = input_mesa1)

}

S7::method(read_longitudinal, OpenLongMesa) <- function(x){
  fnames <- c("mesae2dres06222012.csv", "mesae3dres06222012.csv",
              "mesae4dres06222012.csv", "mesae5_drepos_20220820.csv")
  data_directory <- c("Exam2", "Exam3", "Exam4", "Exam5")
  purrr::map2(
    .x = purrr::set_names(fnames),
    .y = data_directory,
    .f = ~ readr::read_csv(file = file.path(x@filepath,
                                            "Primary",
                                            .y,
                                            "Data",
                                            .x),
                           show_col_types = FALSE,
                           guess_max = Inf)
  )
}


OpenLongAbc <- S7::new_class(
  name = "OpenLongAbc",
  package = 'OpenLong',
  parent = OpenLongData,
  validator = function(self) {

    if(length(self@filepath) == 1){

      # TODO: Brian to add a check for valid filepath
      # (ping Byron to discuss this and see example in Mesa object)

    }

  }
)

S7::method(read_baseline, OpenLongAbc) <- function(x){
  # TODO: Brian to add code here for loading baseline files
  tibble::tibble()
}

S7::method(read_longitudinal, OpenLongAbc) <- function(x){
  # TODO: Brian to add code here for loading longitudinal files
  tibble::tibble()
}
