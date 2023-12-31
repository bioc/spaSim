#' Simulate multiple images with clusters
#'
#' @description Generate a set of images with different cluster properties.
#'   Trying out the default parameters is recommended for understanding this
#'   function. The default values for the arguments give an example of multiple
#'   image simulation which enable an automatic multiple image simulation
#'   without the specification of any argument.
#' @param bg_sample A data frame or `SpatialExperiment` class object with
#'   locations of points representing background cells. Further cell types will
#'   be simulated based on this background sample. The data.frame or the
#'   `spatialCoords()` of the SPE object should have colnames including
#'   "Cell.X.Positions" and "Cell.Y.Positions". By default use the internal
#'   \code{\link{bg1}} background image.
#' @param cluster_shape Number. Choose from one of the following pre-designed
#'   shapes (1 or 2 for tumour cluster or 3 for immune cluster). The
#'   pre-designed shape contains information of the cell names of the cluster,
#'   the infiltration cell types, the proportions of infiltration, the cluster
#'   size, and the cluster centre locations. In order to simulate a set of
#'   images, use the arguments below to specify the ranges of the properties.
#'   The predefined cell types can not be changed, while users can change them
#'   manually after the simulation.
#' @param prop_infiltration Numeric Vector. The degree of infiltration. If
#'   numeric, all simulated images have the same infiltration degree. If vector,
#'   images with a range of different infiltration proportions will be
#'   simulated.
#' @param cluster_size Numeric Vector. The size of the cluster. If numeric, all
#'   simulated images have the same cluster size. If vector, images with a range
#'   of different cluster sizes will be simulated. The size should not exceed
#'   the limit of the image sides.
#' @param cluster_loc_x Numeric or Vector. The X location of the cluster center
#'   offset. If numeric, all simulated images have the same center X location.
#'   If vector, images with a range of different center locations will be
#'   simulated.
#' @param cluster_loc_y Numeric or Vector of the same length of `cluster_loc_x`.
#'   The Y location of the cluster center offset.
#' @param plot_image Boolean Whether plot the simulated images or not.Default is
#'   TRUE.
#' @param plot_categories String Vector specifying the order of the cell
#'   categories to be plotted. Default is NULL - the cell categories under the
#'   "Cell.Type" column would be used for plotting.
#' @param plot_colours String Vector specifying the order of the colours that
#'   correspond to the `plot_categories` arg. Default is NULL - the predefined
#'   colour vector would be used for plotting.
#'
#' @family simulate multiple images functions
#' @seealso \code{\link{multiple_background_images}} for simulating multiple
#'   mixed background images, and
#'   \code{\link{multiple_images_with_immune_rings}} for simulating multiple
#'   images with immune rings.
#'
#' @return A list of SPE objects
#' @export
#' @examples
#' set.seed(610)
#' cluster_image_list <- multiple_images_with_clusters(bg_sample=bg1,
#' cluster_shape=2, prop_infiltration=0.1, cluster_size = seq(200,1000,100),
#' cluster_loc_x = 0, cluster_loc_y = 0, plot_image = TRUE)
multiple_images_with_clusters <- function(bg_sample = bg1,
                                          cluster_shape = 2,
                                          prop_infiltration = 0.1,
                                          cluster_size = seq(200,1000,100),
                                          cluster_loc_x = 0,
                                          cluster_loc_y = 0,
                                          plot_image = TRUE,
                                          plot_categories = NULL,
                                          plot_colours = NULL){

    ## CHECK
    if (!is.data.frame(bg_sample) & !methods::is(bg_sample, "SpatialExperiment")) {
        stop("`bg_sample` should be either a data.frame or a SpatialExperiment object!")
    }
    if(!is.numeric(cluster_size) | !is.numeric(prop_infiltration) |
       !is.numeric(cluster_loc_x) | !is.numeric(cluster_loc_y)){
        stop(" One or more of `cluster_size`, `prop_infiltration`, `cluster_loc_x`, `cluster_loc_y` is not numeric!")
    }
    if(!(cluster_shape %in% c(1, 2, 3))){
        stop("`cluster_shape` must be one of `1`, `2`, and `3`!")
    }
    if (!is.null(plot_categories) & !is.null(plot_categories)){
        if (length(plot_categories) != length(plot_colours)){
            stop("`plot_categories` and `plot_colours` should be of the same length!")
        }
    }

    if (methods::is(bg_sample, "SpatialExperiment")) {
        bg_sample <- get_colData(bg_sample)}

    # count the image number
    i <- 0
    list.images <- list()

    # choose a cluster shape (predefined in the package)
    if (cluster_shape == 1){
        n_clusters <- 3
        infiltration_types <- c("Immune", "Others")
        properties_of_clusters_temp <- C_shape1
        # if the cluster size is too small, adjust the locations of some of the sub shapes
        size_threshold <- 240
    }
    else if(cluster_shape == 2){
        n_clusters <- 2
        infiltration_types <- c("Immune", "Others")
        properties_of_clusters_temp <- C_shape2
        # if the cluster size is too small, adjust the locations of some of the sub shapes
        size_threshold <- 100
    }
    else if (cluster_shape == 3){
        n_clusters <- 1
        infiltration_types <- c("Immune", "Others")
        properties_of_clusters_temp <- C_shape3
        size_threshold <- 0
    }

    # loop through the cluster size and infiltration proportion ranges
    for (size in cluster_size){
        # if the cluster size is too small, adjust the locations of some of the sub shapes
        if (size < size_threshold) {
        }
        for (infil in prop_infiltration){
            y_idx <- 0
            for (loc_x in cluster_loc_x) {
                i <- i + 1 # image count

                # find the corresponding y loc
                y_idx <- y_idx + 1
                loc_y <- cluster_loc_y[y_idx]

                # change the properties of the cluster based on the current loop
                properties_of_clusters <- properties_of_clusters_temp
                for (k in seq_len(length(properties_of_clusters))){
                    # change the sizes of the default shape
                    properties_of_clusters[[k]]$size <- properties_of_clusters[[k]]$size + size
                    # change the default infiltration proportions
                    properties_of_clusters[[k]]$infiltration_proportions[1] <- infil
                    # change the default centre locations
                    properties_of_clusters[[k]]$centre_loc[1] <- properties_of_clusters[[k]]$centre_loc[1] + loc_x
                    properties_of_clusters[[k]]$centre_loc[2] <- properties_of_clusters[[k]]$centre_loc[2] + loc_y
                }

                # simulate the image
                image <- TIS(bg_sample = bg_sample,
                             n_clusters = n_clusters,
                             properties_of_clusters = properties_of_clusters,
                             plot_image = FALSE,
                             plot_categories = plot_categories)

                if (plot_image){
                    if(is.null(plot_categories)) plot_categories <- unique(image$Cell.Type)
                    if (is.null(plot_colours)){
                        plot_colours <- c("gray","darkgreen", "red", "darkblue", "brown", "purple", "lightblue",
                                          "lightgreen", "yellow", "black", "pink")}
                    plot_cells(image, plot_categories, plot_colours[seq_len(length(plot_categories))], "Cell.Type")}
                list.images[[i]] <- image
            }
        }
    }
    return(list.images)
}
