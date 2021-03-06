DIR=$(dirname "$0") # directory of this script
SCENARIO=$DIR/scenarios/typical-midweek-day-in-jan

# Call the plan generation script with the required parameters
Rscript --vanilla -e "source('$DIR/plan-algorithm.R'); buildPopulation(c(
  '$SCENARIO/distributions.csv',
  '$SCENARIO/location_maps.csv',
  '$SCENARIO/numbers.csv',
  '$SCENARIO/travel_factor.csv',
  '$SCENARIO/../../SCS-Locations-2021/SCS-Locations-2021.csv',
  '$SCENARIO/plans.xml'))"

# Call the attribute generator with required parameters
Rscript --vanilla -e "source('$DIR/BDI_attributes.R'); assignAttributes(c(
  '$SCENARIO/numbers.csv',
  '$SCENARIO/dependents.csv',
  '$SCENARIO/thresholds.csv',
  '$SCENARIO/stay.csv',
  '$SCENARIO/prob_go_home.csv',
  '$SCENARIO/plans.xml',
  '$SCENARIO/plans.xml',
  '$SCENARIO/../../Refuges.csv'))"

#
# rm -rf matsim/output/
# unzip matsim/matsim* -d matsim/
# java -cp matsim/matsim-0.9.0/matsim-0.9.0.jar org.matsim.run.Controler matsim/config.xml
# rm -r matsim/matsim-0.9.0/
