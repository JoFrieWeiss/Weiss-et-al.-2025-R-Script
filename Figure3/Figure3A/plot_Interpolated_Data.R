plot_Interpolated_Data <- function(age0, x1, age_interp, x2) {
  
  # age0=climate_df[,c(1)]
  # x1=climate_df[,c(2)]
  # age_interp=age_interp
  # x2=EDC_D.interp[,1]
  # Prepare the original and interpolated dataframes
  
  original_data <- data.frame(Age = age0, x1)
  interpolated_data <- data.frame(Age = age_interp, x2)
  dataname=colnames(original_data)[2]
  # Plotting
  p <- ggplot() + 
    geom_line(data = original_data, aes(x =  original_data[,1], y =original_data[,2]), color = "blue", size = 1) +
    geom_point(data = original_data, aes(x =  original_data[,1], y =original_data[,2]), color = "blue", size = 2) +
    geom_line(data = interpolated_data, aes(x = interpolated_data[,1], y =interpolated_data[,2]), color = "red", size = 1, linetype = "dashed") +
    geom_point(data = interpolated_data, aes(x =  interpolated_data[,1], y =interpolated_data[,2]), color = "red", size = 2) +
   # ggtitle("Comparison of Original and Interpolated Data") +
    xlab("Age") +
    ylab(dataname) +
    theme_bw() +
    scale_color_manual(values = c("blue", "red"), breaks = c("Original", "Interpolated"))+
    scale_x_continuous(breaks = seq(min(interpolated_data[,1]), max(interpolated_data[,1]), by = 2000)) # Here's the modification for x-axis
  
  
  print(p)
}

