
check_if_exists<-function(){
    .
  
    
    if(!file.exists("./UCI HAR Dataset")) {dir.create("./UCI HAR Dataset")
  
                                         
    
    fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
    download.file(fileUrl,destfile="UCI HAR Dataset.zip", method="curl")
                                         

    unzip("UCI HAR Dataset.zip", files = NULL, list = FALSE, overwrite = TRUE, 
          junkpaths = FALSE, exdir = ".", unzip = "internal", setTimes = FALSE)
    }
 
}





readData<-function(main_folder="UCI HAR Dataset", inertial=FALSE){
    
    testData<-firstLevelData(main_folder, "test")
    if(inertial==TRUE) {testData<-readInertialData(testData, main_folder, "test" )}
    testData$train<- 0
    
    trainData<-firstLevelData(main_folder, "train")
    if(inertial==TRUE) {trainData<-readInertialData(trainData, main_folder, "train" )}
    trainData$train<- 1
  
  
    readData<-rbind(testData,trainData)
  
}



firstLevelData<-function(main_folder, type) {
    
  
    X <- read.table(paste(main_folder, type, paste(paste("X", type, sep="_"), "txt", sep="."),sep="/"), dec=".", quote="\"")
   
    features <- read.table(paste(main_folder, paste("features", "txt", sep="."),sep="/"), dec=".", quote="\"")
    colnames(X)<-features$V2
  
    
    subject_test <- read.table(paste(main_folder, type, paste(paste("subject", type, sep="_"), 
                    "txt", sep="."),sep="/"), dec=".", quote="\"")
  
    y <- read.table(paste(main_folder, type, paste(paste("y", type, sep="_"), 
                                        "txt", sep="."),sep="/"), dec=".", quote="\"")
  
   
    X<-cbind(subject_test,y, X)
  
    colnames(X)[1] <- "subject"
    colnames(X)[2] <- "activity"
  
    X$activity<-replaceActivityName(main_folder, X$activity)
  
    return(X)
  
  
}

replaceActivityName<-function (main_folder, activity_col) {
   
    repl.tab <- read.table(paste(main_folder,"activity_labels.txt",sep="/"), dec=".", quote="\"")
  
    
    repl.tab <- data.frame(lapply(repl.tab, as.character), stringsAsFactors=FALSE)
  
    indx <- match(activity_col, repl.tab[, 1], nomatch = 0) 
    activity_col[indx != 0] <- repl.tab[indx, 2] 
    return(activity_col)
  
}


readInertialData<-function(original_df, main_folder, type) {
  
    root_part<-c("body_acc","body_gyro","total_acc")
    second_part<-c("x","y","z")
  
    filenames<-apply(expand.grid(root_part, second_part), 1, paste, collapse = "_")
    filenames<-sort(filenames)
  
    for (i in filenames) 
    {
      
    fullname<-paste(main_folder,type,"Inertial Signals", paste(paste(i,type, sep="_"),"txt", sep="."), sep="/")
    
    fil<-read.table(fullname, dec=".", quote="\"")
     
    subn<-1:128
    coln<-paste(i, subn, sep=".")
    colnames(fil) <- coln
    
    original_df<-cbind(original_df,fil)
    
  }
  return(original_df)
}

extractMeanStdColumns<-function(original_df){
  
    z<-names(original_df)
  

    gh<-grepl("mean()",z, fixed=TRUE)|grepl("std()",z, fixed=TRUE)
  
 
    z<-z[gh]
  
    z<-c("subject", "activity", z, "train")
  
    subset_df<-original_df[,z]
  
    return(subset_df)
}

summarizedData<-function(subset_df){
   
  
    nam<-colnames(subset_df)
    aggregated_df<-aggregate(subset_df[nam[3:length(nam)]], by=subset_df[c("subject","activity")], 
                             FUN=function(x) c(mean=mean(x), std=sd(x)) )
  
    aggregated_df$train<-aggregated_df$train[,1]
    return(aggregated_df)
  
}
