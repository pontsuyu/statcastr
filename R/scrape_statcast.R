#' Scrape statcast data
#'
#' @param start_date Date of first game you want. Format must be in YYYY-MM-DD format.
#' @param end_date Date of last game you want. Format must be in YYYY-MM-DD format.
#'
#' @import dplyr
#' @importFrom magrittr %>%
#' @importFrom foreach foreach %do%
#' @export
#' @examples
#' \dontrun{
#' scrape_statcast(start_date = "2018-04-06", end_date = "2018-04-15")
#' scrape_statcast(start_date = "2018-04-06", end_date = "2018-04-15")
#' }
scrape_statcast <- function(start_date, end_date) {
  if (!is.character(start_date) | !is.character(end_date)) {
    stop("Please wrap your dates in quotations in 'yyyy-mm-dd' format.")
  }
  if (as.Date(start_date) <= "2015-03-01") {
    warning("Some metrics such as Exit Velocity and Batted Ball Events have only been compiled since 2015.")
  }
  if (as.Date(start_date) <= "2008-03-25") {
    stop("The data are limited to the 2008 MLB season and after.")
  }
  if (as.Date(start_date) > as.Date(end_date)) {
    stop("The start date is later than the end date.")
  }

  year <- substr(start_date, 1, 4)
  days <- seq.Date(as.Date(start_date), as.Date(end_date), by = "day")
  start_days <- as.character(days[(1:length(days)) %% 7 == 1])
  end_days <- as.character(days[(1:length(days)) %% 7 == 0])
  res <- list()
  n <- max(length(start_days), length(end_days))
  res <- foreach(i = 1:n) %do% {
    if (i == n) end_days[i] <- end_date
    url <- paste0("https://baseballsavant.mlb.com/statcast_search/csv?all=true&hfPT=&hfAB=&hfBBT=&hfPR=&hfZ=&stadium=&hfBBL=&hfNewZones=&hfGT=R%7CPO%7CS%7C&hfC&hfSea=", year, "%7C&hfSit=&hfOuts=&opponent=&pitcher_throws=&batter_stands=&hfSA=&player_type=&hfInfield=&team=&position=&hfOutfield=&hfRO=&home_road=&game_date_gt=", start_days[i], "&game_date_lt=", end_days[i], "&hfFlag=&hfPull=&metric_1=&hfInn=&min_pitches=0&min_results=0&group_by=name&sort_col=pitches&player_event_sort=h_launch_speed&sort_order=desc&min_abs=0&type=details")
    suppressMessages(suppressWarnings(
      readr::read_csv(url, na = "null")
    )) %>% 
      select(
        game_year,
        game_date,
        game_type,
        home_team,
        away_team,
        game_pk,
        home_score,
        away_score,
        bat_score,
        fld_score,
        post_away_score,
        post_home_score,
        post_bat_score,
        post_fld_score,
        inning,
        inning_topbot,
        strikes,
        balls,
        outs_when_up,
        on_1b,
        on_2b,
        on_3b,
        fielder_1=pitcher_1,
        fielder_2=fielder_2_1,
        fielder_3,
        fielder_4,
        fielder_5,
        fielder_6,
        fielder_7,
        fielder_8,
        fielder_9,
        p_throws,
        pitch_number,
        pitch_type,
        pitch_name,
        release_speed,
        release_pos_x,
        release_pos_z,
        spin_dir,
        pfx_x,
        pfx_z,
        plate_x,
        plate_z,
        vx0,
        vy0,
        vz0,
        ax,
        ay,
        az,
        launch_speed,
        launch_angle,
        effective_speed,
        release_spin_rate,
        release_extension,
        release_pos_y,
        launch_speed_angle,
        zone,
        type,
        batter,
        batter_name=player_name,
        sz_top,
        sz_bot,
        at_bat_number,
        stand,
        events,
        description,
        des,
        bb_type,
        hit_location,
        hc_x,
        hc_y,
        hit_distance_sc
      )
  }
  
  res_data <- do.call("rbind", res) %>% 
    arrange(game_year, game_date, game_pk, inning, desc(inning_topbot), at_bat_number, pitch_number) %>% 
    as.data.frame()
  return(res_data)
}

