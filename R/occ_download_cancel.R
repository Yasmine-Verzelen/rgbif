#' Cancel a download process.
#'
#' @export
#'
#' @param key A key generated from a request, like that from \code{occ_download}. Required.
#' @param user (character) User name within GBIF's website. Required.
#' @param pwd (character) User password within GBIF's website. Required.
#' @param ... Further args passed to \code{\link[httr]{DELETE}}
#'
#' @examples \dontrun{
#' occ_download_cancel(key="0003984-140910143529206")
#' }

occ_download_cancel <- function(key, user=getOption("gbif_user"), pwd=getOption("gbif_pwd"), ...) {
  stopifnot(!is.null(key))
  url <- sprintf('http://api.gbif.org/v1/occurrence/download/request/%s', key)
  res <- DELETE(url, c(authenticate(user = user, password = pwd), list(...)))
  stop_for_status(res)
  if (res$status_code == 204) message("Download sucessfully deleted")
}

#' @export
#' @rdname occ_download_cancel
occ_download_cancel_staged <- function() {
  hh <- occ_download_list()$results
  run_or_prep <- hh[ hh$status %in% c("RUNNING","PREPARING"), "key" ]
  lapply(run_or_prep, occ_download_cancel)
  invisible()
}