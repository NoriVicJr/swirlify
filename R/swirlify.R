# Write a single unit using shiny GUI
write_unit <- function(lessonFile) {
  # Returns unit info, "done" if done, or "test" if testing
  vals <- shiny::runApp(system.file("authoring-gui", package="swirlify"),
                        launch.browser = rstudio::viewer)
  # If "done" or "test" then user is done
  if(identical(vals, "done") || identical(vals, "test")) {
    return(vals)
  }
  # Write unit info to file
  cat(paste0("\n- ", paste0(names(vals), ": ", vals, collapse="\n  "), "\n"),
      file=lessonFile, append=TRUE)
  # Return TRUE if user not done yet
  return(TRUE)
}

make_lesson <- function(lesson, course) {
  # Make course directory name
  courseDir <- gsub(" ", "_", course)
  # Create path to lesson directory
  lessonDir <- file.path(courseDir, gsub(" ", "_", lesson))
  # NOTE: If we add .yaml, the file won't open automatically
  lessonFile <- file.path(lessonDir, "lesson")
  # Check if lesson directory exists  
  if(!file.exists(lessonDir)) {
    message("Creating directory ", lessonDir, " in your current
            working directory...")
    dir.create(lessonDir, recursive=TRUE)
    writeLines(c(
      "# Put initialization code in this file. The variables you create", 
      "# here will show up in the user's workspace when he or she begins", 
      "# the lesson."), file.path(lessonDir, "initLesson.R"))
    writeLines("# Put custom tests in this file.", 
               file.path(lessonDir,"customTests.R"))
    writeLines(c("- Class: meta", 
                 paste("  Course:", course),
                 paste("  Lesson:", lesson),
                 "  Author: Your name goes here",
                 "  Type: Standard",
                 "  Organization: Your organization goes here (optional)",
                 paste("  Version:", packageVersion("swirl"))),
               lessonFile)
  } else {
    message(lessonDir, " already exists in the current working directory")
  }
  message("\nOpening lesson for editing...")
  file.edit(lessonFile)
  return(lessonFile)
}

#' Author lesson using content authoring tool
#' 
#' @param lesson lesson name
#' @param course course name
#' @examples
#' \dontrun{
#' 
#' swirlify("Linear Regression", Statistics 101")
#' }
#' @import shiny
#' @import swirl
#' @importFrom methods loadMethod
#' @export
swirlify <- function(lesson, course) {
  # Create course skeleton and open new lesson file
  lessonFile <- make_lesson(lesson, course)
  # Initialize result
  result <- TRUE
  # Loop until user is done
  while(isTRUE(result)) {
    result <- write_unit(lessonFile)
  }
  if(identical(result, "test")) {
    # Make course directory name
    courseDir <- gsub(" ", "_", course)
    # Install course
    install_course_directory(courseDir)
    # Run lesson in "test" mode
    swirl("test", test_course=course, test_lesson=lesson)
  }
  invisible()
}