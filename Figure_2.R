################################################################################
#### Dominance of Phaeocystis antarctica during the Antarctic Cold Reversal ####
################# detected by sedimentary ancient DNA ##########################
########################## R Script J.Weiß #####################################
###################### Cite: Weiß et al., 2023 #################################
################################################################################

# First step: Adding metadaten and tax lineage to kraken output
# nt 0.8 and 35 kmer

library("dplyr")
library("tidyverse")
library("readxl")
library("tidypaleo")
library("ggplot2")
library("readr")

# Upload data files from first sequencing run

antarcticaPS97_nt35_conf0.8 <- read.delim("~/output_0.8_35/antarcticaPS97_nt35_conf0.8.txt", 
                                          header=FALSE)
antarcticaPS97_nt35_conf0.8
names(antarcticaPS97_nt35_conf0.8) <- c("samples", "percent", "clade_count", 
                                        "tax_count", "rank", "taxid", "name")
nt <- rename(antarcticaPS97_nt35_conf0.8)
str(antarcticaPS97_nt35_conf0.8$taxid)
antarcticaPS97_nt35_conf0.8$taxid=as.character(antarcticaPS97_nt35_conf0.8$taxid)
taxid_lin  <-X_lineageDB
names(taxid_lin)
str(taxid_lin$taxid)
taxid_lin <-taxid_lin %>% rename(taxid=taxID)

## then just join the two tables
nt_tax_lin=left_join(antarcticaPS97_nt35_conf0.8, taxid_lin, by="taxid")
nt_tax_lin
#add metadata
ngs_sample=read_xlsx(paste0("~/antarcticaPS97_sample_name_change_new.xlsx"), 
                     sheet = "Sheet1", col_names = T)
## then just join the two tables
nt_tax_lin_meta=left_join(ngs_sample, nt_tax_lin, by="samples")
# save as csv
write.csv2(nt_tax_lin_meta, paste0("~/antarcticaPS97_query_lineage_split1_0.8_35kmer.csv"))
#rename dataset
sgdf=nt_tax_lin_meta
#filter for samples only, discard blanks
sgdf_samples=sgdf %>% filter(type=="sample")
names(sgdf_samples)

#Upload Data Files JoW007L sequencing run
PS97_JoW007L_nt0.8_Kraken2 <- read.delim("~/output_0.8_35/PS97_JoW007L_nt0.8_Kraken2.txt", 
                                         header=FALSE)
PS97_JoW007L_nt0.8_Kraken2
names(PS97_JoW007L_nt0.8_Kraken2) <- c("samples", "percent", "clade_count",
                                       "tax_count", "rank", "taxid", "name")
nt <- rename(PS97_JoW007L_nt0.8_Kraken2)
str(PS97_JoW007L_nt0.8_Kraken2$taxid)
PS97_JoW007L_nt0.8_Kraken2$taxid=as.character(PS97_JoW007L_nt0.8_Kraken2$taxid)
taxid_lin  <-JoW007L_csv_lineageDB
names(taxid_lin)
str(taxid_lin$taxid)
taxid_lin <-taxid_lin %>% rename(taxid=taxID)

## merge the two tables
nt_tax_lin=left_join(PS97_JoW007L_nt0.8_Kraken2, taxid_lin, by="taxid")
nt_tax_lin
#add metadata
ngs_sample <- JoW007L_1_8_new_shotgun_sample_name_change
ngs_sample=read_xlsx(paste0("~/antarcticaPS97_sample_name_change_new.xlsx"), 
                     sheet = "Sheet1", col_names = T)
## merge the two tables again
nt_tax_lin_meta=left_join(ngs_sample, nt_tax_lin, by="samples")
# save as csv
write.csv2(nt_tax_lin_meta, paste0("~AntarcticaPS97_JoW007L_query_lineage_split1_0.8_35kmer.csv"))
#rename dataset
sgdf=nt_tax_lin_meta
#filter for samples only, discard blanks
sgdf_samples_JoW007L=sgdf %>% filter(type=="sample")
names(sgdf_samples_JoW007L)

# Second step: Filtering for merged read_fraction and of eukaryotic taxa in 
# both sequencing datasets

sgdf_samples_new = sgdf_samples %>% filter(read_fraction == "merged")
sgdf_samples_JoW007L_new = sgdf_samples_JoW007L %>% filter(read_fraction == "merged")
EUKARY=sgdf_samples_new %>% filter(superkingdom=="Eukaryota")
EUKARY_JoW007=sgdf_samples_JoW007L_new %>% filter(superkingdom=="Eukaryota")

#merge both files together 
sgdf_combined <- rbind(sgdf_antarctic, sgdf_antarctic_JoW007L)

# Third step: Look at data for Primary Producer at genus level and prepare for Resampling 

Phytoplankton= sgdf_combined %>% filter(phylum %in% c("Cyanobacteria", 
                                                      "Haptophyta", "Chlorophyta", 
                                                      "Bacillariophyta"))
Phytoplankton_1 <- Phytoplankton %>%
  group_by(genus,age) %>%
  summarise(sumcount = sum(clade_count))

Phytoplankton_2 <- Phytoplankton_1 %>%
  group_by(age) %>% 
  mutate(rel_abund = (sumcount / sum(sumcount))*100)

Phytoplankton_for_resampling <- subset(Phytoplankton_2, rel_abund > 1.0)

view(Phytoplankton_for_resampling)

# Remove rows starting with "Gen_In" to get rid of taxa that are not at least classified to genus level
Phytoplankton_for_resampling_filtered <- Phytoplankton_for_resampling[!grepl("^Gen_in_", 
                                                                             Phytoplankton_for_resampling$genus), ]

# Get rid of relative abundance again
Phytoplankton_for_resampling_filtered_2 <- subset(Phytoplankton_for_resampling_filtered,
                                                  select = -rel_abund)

view(Phytoplankton_for_resampling_filtered_2)

# Create a pivot table to set every NA to 0 and for resampling 
Phytoplankton_for_resampling_filtered_wide <- pivot_wider(data=Phytoplankton_for_resampling_filtered_2, 
                                                          names_from = genus,  
                                                          values_from = sumcount)

Phytoplankton_for_resampling_filtered_wide[is.na(Phytoplankton_for_resampling_filtered_wide)] <- 0

# resampling based on Stefan Kruse https://github.com/StefanKruse/R_Rarefaction

# after resampling: 
t_ordidf <- as.data.frame(t(ordidf1321_aggregated), header = F)
# apply header
names(t_ordidf) <- t_ordidf[1,]
# cut out double information
t_ordidf <- t_ordidf[-1,] 
view(t_ordidf)

# Have age as a column not as rownames
t_ordidf$age <- row.names(t_ordidf)
view(t_ordidf)
t_ordidf <- t_ordidf %>%
  dplyr::select(age, everything())
view(t_ordidf)

PS97_phyto_resampled <- t_ordidf %>%
  pivot_longer(!age, names_to = "name", values_to = "sumcount")  

view(PS97_phyto_resampled)

write.csv2(PS97_phyto_resampled, paste0("~/PS97_phyto_resampled.csv"), row.names=FALSE)	
# adding group again for plotting in Excel 
PS97_phyto_resampled_grouped <- read.delim2("~/PS97_phyto_resampled_grouped.txt")

PS97_phyto_resampled_grouped_1 <- PS97_phyto_resampled_grouped %>%
  group_by(group,age) %>%
  summarise(sumcount_1 = sum(sumcount))

PS97_phyto_resampled_grouped_2 <- PS97_phyto_resampled_grouped_1 %>%
  group_by(age) %>% 
  mutate(rel_abund = (sumcount_1 / sum(sumcount_1))*100)

PS97_phyto_resampled_grouped_3=PS97_phyto_resampled_grouped_2 %>% filter(!is.na(group))

P <- ggplot(PS97_phyto_resampled_grouped_3, aes(x=age, y=rel_abund,fill=group)) +
  geom_area(position="identity")+
  facet_abundance(vars(group),scales = "free", space="fixed")+
  scale_x_continuous(breaks = round(seq(min(0), max(14000), by =1000),1))+
  theme(panel.background = element_blank())+ theme(axis.line.x = element_line(color="black", size = 0.5),
                                                   axis.line.y = element_line(color="black", size = 0.5), legend.position = "none")
P+ scale_fill_brewer(palette = "Greens", direction = 1)


###############################################################################
####################### Ice Core data of Epica DOME C #########################
############### by Monnin et al., 2001 and Jouzel et al., 2007 ################
###############################################################################

library(ggplot2)
library(ggpubr)

# Import data from text files.
EDC_TEMP <- read.delim("EDC_TEMP.txt")
EPICA_ICECORE <- read.delim("EPICA_gas.txt")

# Transform temperature to float/double for visualization.
EDC_TEMP$EDC__D <- as.numeric(gsub(",", ".", EDC_TEMP$EDC__D))
EPICA_ICECORE$Gas.age..ka.BP. <- EPICA_ICECORE$Gas.age..ka.BP./1000
# Define rough ratio between EDC & NGRIP temperature and apply below.
translator <- 650

############ Create plot ###########
plot_IceCore <- ggplot() +
  
  # Draw lines, apply color and transparency.
  #geom_line(data = EPICA_ICECORE, aes(x = Gas.age..ka.BP., y = CO2..ppmv.), color = "black", alpha = .5) +
  #geom_line(data = EDC_TEMP, aes(x = Age, y = EDC__D + translator), color = "darkblue", alpha = .5) +
  
  # Scale axis (NGRIP), apply translation coefficient for second y axis (EDC).
  scale_x_continuous(breaks = round(seq(min(0), max(17000), by = 1000), 1)) +
  scale_y_continuous(name = expression(paste("CO"[2], "(ppmv)")), sec.axis = sec_axis(trans = ~.-translator, name = "Antarctic Temperature (°C)")) +
  
  # Apply settings for axis.
  theme(panel.background = element_blank(),
        axis.line.x = element_line(color = "black", size = .5),
        axis.line.y = element_line(color = "black", size = .5)) +
  
  # Draw smoothed mean according to settings.
  geom_smooth(data = EPICA_ICECORE, aes(x = Gas.age..ka.BP., y = CO2..ppmv.),
              span = .1, level = .99, color = "black", alpha = .2, linewidth = .7) +
  geom_smooth(data = EDC_TEMP, aes(x = Age, y = EDC__D + translator),
              span = .1, level = .99, color = "darkblue", alpha = .2, linewidth = .7) #+

# Write labels to graphs.
#geom_text(aes(x = 300, y = -36, label = "EPICA_ICECORE", fontface = "bold"), color = "black", alpha = .5) +
#geom_text(aes(x = 300, y = -41, label = "EDC", fontface = "bold"), color = "darkblue", alpha = .5)

# Draw the plot.
plot_IceCore 

###############################################################################
######################## XRF transformation script ############################
######################## ratio alr() transformation ###########################
###############################################################################

library(compositions)
attach(XRF_ratios)
(ratios <- alr(c(2,3,4,5,6,7,8,9)))
alrInv(ratios)
pairs(alr(XRF_ratios),pch=".")
detach(XRF_ratios)

XRF_ratios$PS97.72.1.Depth..mm.
xrf_ratio <- select(XRF_ratios, -PS97.72.1.Depth..mm.)

(xrf_alr <- alr(xrf_ratio))
#alrInv(xrf_alr)
unclass(alrInv(tmp)) - clo(c(1,2,3)) # 0
data(Hydrochem)
cdata <- Hydrochem[,6:19]
pairs(alr(xrf_ratio),pch=".")

pairs(xrf_alr, pch=".")
write.csv2(xrf_alr,paste0("~/xrf_alr.csv"))

# Attach age to Ba/Fe ratio in Excel also using linear Interpolation using =FORECAST
# reupload of data to Age_Ba.Fe_alr_transformed

#getting rid of NA ROWS in dataset

Age_Ba.Fe_new<-Age_Ba.Fe_alr_transformed[complete.cases(Age_Ba.Fe_alr_transformed),]


BAFE <- ggplot(Age_Ba.Fe_new, aes(x=Age..yr., y=Ba.Fe)) +
  geom_smooth(span=0.1, level=0.99,colour="black", size=1)+
  scale_x_continuous(breaks = round(seq(min(0), max(14000), by =1000),1))+
  theme(panel.background = element_blank())+theme(axis.line.x = element_line(color="black", size = 0.5),
                                                  axis.line.y = element_line(color="black", size = 0.5))

BAFE_neu <- BAFE + ggtitle("Ba/Fe") +
  xlab("Age (kyr BP)")

###############################################################################
############################ Sea Ice Biomarker ################################
########################### Vorrath et al., 2023 ##############################
###############################################################################

# Biomarker PIPSO25

Biomarker_For_Paper_April2023$Cal..Ages.BP <- Biomarker_For_Paper_April2023$Cal..Ages.BP *1000
Biomarker_For_Paper_April2023$PIPSO25


PIPSO25 <- ggplot(Biomarker_For_Paper_April2023, aes(x=Cal..Ages.BP, y=PIPSO25)) +
  geom_smooth(span=0.1, level=0.99,colour="black", size=1)+
  scale_x_continuous(breaks = round(seq(min(0), max(14000), by =1000),1))+
  theme(panel.background = element_blank())+theme(axis.line.x = element_line(color="black", size = 0.5),
                                                  axis.line.y = element_line(color="black", size = 0.5))

###############################################################################
######################### Bacteria Methylotrophs ##############################
###############################################################################

#family of Methylotrophs 
sgdf_fam_methylotrophs =sgdf_samples %>% filter(family %in% c("Methylophilaceae", 
                                                              "Methylobacteriaceae", 
                                                              "Hyphomicrobiaceae", 
                                                              "Beijerinckiaceae", "Methylococcaceae"))

sgdf_fam_methylotrophs_JoW007L = sgdf_samples_JoW007L %>% filter(family %in% c("Methylophilaceae", 
                                                                               "Methylobacteriaceae",
                                                                               "Hyphomicrobiaceae",
                                                                               "Beijerinckiaceae", 
                                                                               "Methylococcaceae"))

# additionally we include Methylophaga as genus because in Rhodobacteraceae 
# are too many non methylotrophic bacteria
# Methylophaga
sgdf_Methylophaga = sgdf_samples %>% filter(genus=="Methylophaga")
sgdf_Methylophaga_JoW007L = sgdf_samples_JoW007L %>% filter(genus=="Methylophaga")

#Combine all of them
sgdf_combined_methylotrophs = rbind(sgdf_Methylophaga,sgdf_Methylophaga_JoW007L,
                                    sgdf_fam_methylotrophs, sgdf_fam_methylotrophs_JoW007L)

# Community composition
sgdf_combined_methylotrophs_1 <- sgdf_combined_methylotrophs %>%
  group_by(genus,age) %>%
  summarise(sumcount = sum(clade_count))

# remove NAs
sgdf_combined_methylotrophs_1_wide <- pivot_wider(sgdf_combined_methylotrophs_1,
                                                  names_from = genus,  
                                                  values_from = sumcount)

sgdf_combined_methylotrophs_1_wide[is.na(sgdf_combined_methylotrophs_1_wide)] <- 0

sgdf_combined_methylotrophs_1_long <- sgdf_combined_methylotrophs_1_wide %>%
                                        pivot_longer(!age, names_to = "name",
                                                     values_to = "sumcount")  
# Combine with Phytoplankton 

sgdf_methylotrophs_and_phytoplankton <- rbind(sgdf_combined_methylotrophs_1_long, Phytoplankton_for_resampling_filtered_2)

sgdf_methylotrophs_and_phytoplankton_relabund <- sgdf_methylotrophs_and_phytoplankton %>% 
                                                  group_by(age) %>% 
                                                  mutate(rel_abund = (sumcount / sum(sumcount))*100)

# only cut out the phytoplankton species for plotting

sgdf_methylotrophs_and_phytoplankton_relabund_filtered <- sgdf_methylotrophs_and_phytoplankton_relabund[!grepl("Chaetoceros", "Phaeocystis",
                                                                                                               "Fragilariospis",
                                                                             sgdf_methylotrophs_and_phytoplankton_relabund$name), ]

sgdf_methylotrophs_and_phytoplankton_relabund_filtered_3 = sgdf_methylotrophs_and_phytoplankton_relabund_filtered %>%
                                                            filter(!is.na(name))


Methylotrophic_plot <- ggplot(sgdf_methylotrophs_and_phytoplankton_relabund_filtered_3, aes(x=age, y=rel_abund)) +
  geom_area(position="identity")+
  facet_abundance(vars(name),scales = "free", space="fixed")+
  scale_x_continuous(breaks = round(seq(min(0), max(14000), by =1000),1))+
  theme(panel.background = element_blank())+ theme(axis.line.x = element_line(color="black", size = 0.5),
                                                   axis.line.y = element_line(color="black", size = 0.5), 
                                                   legend.position = "none")

################################################################################
###################### Ecosystem composition plot ##############################
################################################################################

sgdf_Metazoa = sgdf_combined %>% filter(phylum %in% c("Arthropoda", "Mollusca", 
                                                     "Chordata", "Echinodermata", 
                                                     "Hydrozoa", "Platyhelminthes", 
                                                     "Nematoda", "Annelida"))
sgdf_Metazoa_1 <- sgdf_Metazoa %>%
  group_by(family,age) %>%
  summarise(sumcount = sum(clade_count))

# remove NAs
sgdf_Metazoa_1_wide <- pivot_wider(data=sgdf_Metazoa_1, 
                                   names_from = family,  
                                   values_from = sumcount)

sgdf_Metazoa_1_wide[is.na(sgdf_Metazoa_1_wide)] <- 0

view(sgdf_Metazoa_1_wide)

sgdf_Metazoa_1_long <- sgdf_Metazoa_1_wide %>%
  pivot_longer(!age, names_to = "family", values_to = "sumcount")

# calculate relative abundance

sgdf_Metazoa_2 <- sgdf_Metazoa_1_long %>%
  group_by(age) %>% 
  mutate(rel_abund = (sumcount / sum(sumcount))*100)

# Search for only Antarctic families
sgdf_Ecosystem = sgdf_Metazoa_2 %>% filter(family %in% c("Euphausiidae", 
                                                         "Metridinidae", 
                                                         "Temoridae", 
                                                         "Iphimediidae", 
                                                         "Lysianassidae", 
                                                         "Spheniscidae", 
                                                         "Balaenopteridae", 
                                                         "Delphinidae", 
                                                         "Phocidae",
                                                         "Nototheniidae",
                                                         "Channichthyidae", 
                                                         "Bathydraconidae"))

sgdf_Ecosystem_3 = sgdf_Ecosystem %>% filter(!is.na(family))

sgdf_Ecosystem_3$new_name = factor(sgdf_Ecosystem_3$family, levels=c("Euphausiidae", 
                                                                     "Metridinidae",
                                                                     "Temoridae", 
                                                                     "Iphimediidae",
                                                                     "Lysianassidae",
                                                                     "Spheniscidae", 
                                                                     "Balaenopteridae", 
                                                                     "Delphinidae", 
                                                                     "Phocidae",
                                                                     "Bathydraconidae",
                                                                     "Nototheniidae",
                                                                     "Channichthyidae"), 
                                   labels=c("Euphausiidae", 
                                            "Metridinidae", 
                                            "Temoridae", 
                                            "Iphimediidae", 
                                            "Lysianassidae", 
                                            "Spheniscidae", 
                                            "Balaenopteridae",
                                            "Delphinidae",
                                            "Phocidae",
                                            "Bathydraconidae",
                                            "Nototheniidae","Channichthyidae"))



# Adding in Excel the family groups
# Euphausiidae = Krill 
# Metridinidae, Temoridae, Iphimediidae, Lysianassidae = Copepods 
#     -> Redoing the names to marine copepods to not plot them individually
# Balaenopteridae, Phocidae, Delphinidae = marine mammals 
# Bathydraconidae, Nothoteniidae, Channichthyidae = Fishes
# Spheniscidae show throughout the time nearly 100 % of Pygoscelis antarcticus 
#   that is why we use it with the species information

Ecosystem_plot <- ggplot(sgdf_Ecosystem_3, aes(x=age, y=rel_abund,fill=group)) + 
  geom_area(position="identity")+
  facet_abundance(vars(new_name),scales = "free", space="fixed")+
  scale_x_continuous(breaks = round(seq(min(0), max(14000), by =1000),1))+
  theme(panel.background = element_blank())+ theme(axis.line.x = element_line(color="black", size = 0.5),
                                                   axis.line.y = element_line(color="black", size = 0.5), 
                                                   legend.position = "none")

Ecosystem_plot_2 <- Ecosystem_plot + scale_fill_brewer(palette = "BrBG", direction = -1)

################################################################################
########################## Align all together ##################################
############################# in Inkscape ######################################
################################################################################


