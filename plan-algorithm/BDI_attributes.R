assignAttributes<-function (arglist = NULL)
{
  
options(stringsAsFactors = F)

read_numbers<- function(numbers_file)
{
  df<-read.csv(numbers_file,header = F,sep=',', stringsAsFactors = F,strip.white = T)
  NUMBERS<-vector()
  
  for (row in 1:nrow(df))
  {
    
    if (floor(row/2)!=row/2)#hacky FIX
    {
      Type<-df[row,1] 
    }
    else
    {
      number<-as.numeric(df[row,1])
      names(number)<-Type 
      NUMBERS<-c(NUMBERS,number)
    }
    
  }
  return(NUMBERS)
  
}

read_dependents<- function(dependents_file)
{
  df<-read.csv(dependents_file,header = F,sep=',', stringsAsFactors = F,strip.white = T)
  NUMBERS<-vector()
  
  for (row in 1:nrow(df))
  {
    
    if (floor(row/2)!=row/2)#hacky FIX
    {
      Type<-df[row,1] 
    }
    else
    {
      number<-as.numeric(df[row,1])
      names(number)<-Type 
      NUMBERS<-c(NUMBERS,number)
    }
    
  }
  return(NUMBERS)
  
}

read_thresholds<- function(thresholds_file)
{
  df<-read.csv(thresholds_file,header = F,sep=',', stringsAsFactors = F,strip.white = T)
  NUMBERS<-list()
  df<-as.matrix(df)
  for (row in 1:nrow(df))
  {
    
    if (row%%3==1)#hacky FIX
    {
      
      if(row>1){NUMBERS[[Type]]<-number}
      number<-vector()
      Type<-df[row] 
    }
    else
    {
      score<-as.numeric(df[row,2])
      names(score)<-df[row,1]
      number<-c(number,score)
    }
    
  }
  NUMBERS[[Type]]<-number
  return(NUMBERS)
  
}
read_locations_from_csv<-function(locations_csv_file)
{
  ## If Locations csv file is altered (i.e. a new source shp file), the names of the relevant columns might need to be changed here
  print("Reading locations from Refuges.csv...")
  location_title = "Name"
  xcoord_title = "xcoord"
  ycoord_title = "ycoord"
  evac_priority_title="Popularity"
  
  #read csv
  locs<-read.csv(locations_csv_file,stringsAsFactors = F)
  #reduce to necessary information
  locations<-locs[,c(location_title,xcoord_title,ycoord_title)]
  locs<-locs[locs[,evac_priority_title]>3,]
  evac_locations<-locs[,c(location_title,xcoord_title,ycoord_title)]
  # #distance matrix for all localities
  # 
  # d=as.matrix(dist(locations[locations[[location_type_title]]==base_node_id,3:4]))
  # locales<-locations[rownames(d),][[locality_title]]
  # rownames(d)<-locales
  # colnames(d)<-locales
  # 
  # 
   LOCATIONS<-list(locations=locations,evac_locations=evac_locations)
  return(LOCATIONS)
}

write_attribute_plan<- function (plan_attributes,locations,input_location,output_location)
{

base_plan<-read.delim(input_location, header = F,sep="\n",quote="")



broke<-strsplit(base_plan$V1,"person",fixed=F)
broke<-unlist(broke)
i=1
plans<-file(output_location, open = "w+")

for (i in 1:length(broke))
{
if (grepl("id=",broke[i],fixed=T))
      {
        attrib=paste0(" <person",broke[i],'\n')
        home=strsplit(broke[i+2],"\"",fixed=T) 
        
        if (length(plan_attributes)>0)
        { 
           
          agent<-plan_attributes[[1]]
          
          if (agent$dep==1) #HACKYFIX
          {
            
            depx=as.numeric(home[[1]][4])+(-1)*20*runif(1)
            depy=as.numeric(home[[1]][6])+(1)*20*runif(1)
            dep=paste0(depx,",",depy)
            deph=1*agent$homer
          }
          else
          {
            dep=""
            deph=0
          }
          ghf=1*agent$homer-deph
          #convert to boolean
          boolean<-c("false","true")
          deph=boolean[deph+1]
          ghf=boolean[ghf+1]
          
          home_loc<-c(as.numeric(home[[1]][4]),as.numeric(home[[1]][6]))
          #find Euclidean distance between home and potential destinations
          distances=locations$locations[,2:3]-unlist(matrix(home_loc,nrow(locations$locations),2,byrow = T))
          distances=distances^2
          distances=sqrt(rowSums(distances))
          distances=distances[distances!=0] #remove home from activity list if it is there
          
          #choose based on inverse square law ##ASSUMPTION
          invac_p=sample(distances,1,prob = 1/(distances^2))
          invac=locations$locations[which(distances==invac_p),][1,]
          
          distances=locations$evac_locations[,2:3]-unlist(matrix(home_loc,nrow(locations$evac_locations),2,byrow = T))
          distances=distances^2
          distances=sqrt(rowSums(distances))
          distances=distances[distances!=0] #remove home from activity list if it is there
          evac_p=sample(distances,1,prob = distances^2)
          evac=locations$evac_locations[which(distances==evac_p),][1,]
         
          attrib=paste0(attrib,'    <attributes>\n')
          attrib=paste0(attrib,'      <attribute name="BDIAgentType" class="java.lang.String" >io.github.agentsoz.ees.agents.bushfire.',agent$subgroup,'</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="HasDependents" class="java.lang.String" >',ifelse(dep=="", "false", "true"),'</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="HasDependentsAtLocation" class="java.lang.String" >',dep,'</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ResponseThresholdInitial" class="java.lang.Double" >0.',agent$init_response,'</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ResponseThresholdFinal"   class="java.lang.Double" >0.',agent$final_response,'</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="WillGoHomeAfterVisitingDependents" class="java.lang.Boolean" >',deph,'</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="WillGoHomeBeforeLeaving" class="java.lang.Boolean" >',ghf,'</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="EvacLocationPreference" class="java.lang.String">',evac[1],',',evac[2],',',evac[3],'</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="InvacLocationPreference" class="java.lang.String">',invac[1],',',invac[2],',',invac[3],'</attribute>\n')
          
          # some initial archetypes-based defaults (averages across all archetypes)
          attrib=paste0(attrib,'      <attribute name="Archetype" class="java.lang.String" >MadeUpArchetype</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromFireDangerIndexRating" class="java.lang.String" >0.04</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromImmersionInSmoke" class="java.lang.String" >0.2</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromMessageAdvice" class="java.lang.String" >0.04</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromMessageEmergencyWarning" class="java.lang.String" >0.14</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromMessageEvacuateNow" class="java.lang.String" >0.24</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromMessageRespondersAttending" class="java.lang.String" >0.01</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromMessageWatchAndAct" class="java.lang.String" >0.07</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromSocialMessage" class="java.lang.String" >0.29</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromVisibleEmbers" class="java.lang.String" >0.3</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromVisibleFire" class="java.lang.String" >0.5</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromVisibleResponders" class="java.lang.String" >0.1</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="ImpactFromVisibleSmoke" class="java.lang.String" >0.11</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="LagTimeInMinsForFinalResponse" class="java.lang.String" >12.86</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="LagTimeInMinsForInitialResponse" class="java.lang.String" >15</attribute>\n')
          attrib=paste0(attrib,'      <attribute name="WillStay" class="java.lang.String" >false</attribute>\n')
            
          
          attrib=paste0(attrib,'    </attributes>')

          #broke=append(broke,attrib,i)
          #broke=c(broke[1:i],attrib,broke[i+1:length(broke)])
          plan_attributes[[1]]<-NULL
        }
      }
  else if (grepl("</",broke[i],fixed=T) & nchar(broke[i])==4 )
  {
    attrib=paste0(broke[i],"person>")
    broke[i+1]=""
  }
  else if(broke[i]=="  <")
  {
    attrib=""
  }
  else 
  {
    attrib=paste0(broke[i])
  }
  cat(attrib,file = plans, append=, sep = "\n")
}
close(plans)
}

set_attributes<- function(numbers,dependents,thresholds,stay,ghf)
{
  AGENTS<-list()
  for (subgroup in names(numbers))
  {
    for (i in 1:numbers[subgroup])
    {
    dep=0
    if (runif(1)<dependents[subgroup])
      {
        dep=1
        init_response<-sample(thresholds[[subgroup]][1]:min(3,thresholds[[subgroup]][2]),1) #all with  dependents will respond to evacuate now warning
      }
    else
      {
        init_response<-sample(thresholds[[subgroup]][1]:thresholds[[subgroup]][2],1)
      }
    if (stay[subgroup]==T)
      {
        final_response<-max(init_response,sample(init_response:thresholds[[subgroup]][2],1))
      }
      else
      {
        final_response<-init_response
      }
    if (final_response<init_response)
    {
      print("ERROR: final response is less than initial response")
    }
    
    if (runif(1)<ghf[subgroup])
    {
      homer<-1
    }
    else
    {
      homer<-0
    }
    sub<-strsplit(subgroup," ") #HACKY FIX
    sub<-unlist(sub)
    if (length(sub)>1)
    {
      sub<-paste0(sub[2],sub[1])  
    }
    
    AGENTS[[paste0(subgroup,"_",i)]]<-list(subgroup=sub,dep=dep,init_response=init_response,final_response=final_response,homer=homer)
    }
  }
 return (AGENTS) 
}

# Main starts here

  if (is.null(arglist)) {
    args<-commandArgs(trailingOnly = T)
  } else {
    args <- arglist
  }

  numbers<-read_numbers(numbers_file = args[1])
  dependents<-read_dependents(dependents_file = args[2])
  thresholds<-read_thresholds(thresholds_file = args[3])
  stay<-read_dependents(dependents_file = args[4])
  go_home_prob<-read_numbers(numbers_file = args[5])
  locations<-read_locations_from_csv(locations_csv_file = args[8])
  plan_attributes<-set_attributes(numbers,dependents,thresholds,stay,go_home_prob)
  print("Appending BDI attributes to agents...")
  write_attribute_plan(plan_attributes,locations=locations,input_location = args[7],output_location = args[6])
}

assignAirleysAttributes <- function() {
  args<-c("scenarios/scs-2020-aireys-inlet/numbers.csv",
          "scenarios/scs-2020-aireys-inlet/dependents.csv",
          "scenarios/scs-2020-aireys-inlet/thresholds.csv",
          "scenarios/scs-2020-aireys-inlet/stay.csv",
          "scenarios/scs-2020-aireys-inlet/prob_go_home.csv",
          "scenarios/scs-2020-aireys-inlet/plans.xml",
          "scenarios/scs-2020-aireys-inlet/_plan.xml",
          "Refuges.csv"
  )
  assignAttributes(args)
}