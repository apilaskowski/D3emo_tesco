data = read.csv("7.csv",header = TRUE, sep =",")
library(dummies)
library(randomForest)
library(e1071)

measureRF <- c()
measureTESCO <- c()
measureSVM = c()
for (i in sort(unique(data$retail_outlet_number))){
  new_data_i = data[data$retail_outlet_number==i,c(12,11,6,14)]
  order_data_i = new_data_i[order(as.Date(new_data_i$calendar_date, format="%d/%m/%Y")),]
  final_data_i = c()
  
  if (dim(order_data_i)[1]>= 8) {
  for (j in 8:(dim(order_data_i)[1])){
    if (as.Date(order_data_i$calendar_date[j],"%d/%m/%Y")-7 == as.Date(order_data_i$calendar_date[j-7],"%d/%m/%Y")) {
      final_data_i = rbind(final_data_i,c(order_data_i[j,1],
                                          order_data_i[j,2],
                                          order_data_i[j-1,1],
                                          order_data_i[j-2,1],
                                          order_data_i[j-3,1],
                                          order_data_i[j-4,1],
                                          order_data_i[j-5,1],
                                          order_data_i[j-6,1],
                                          order_data_i[j-7,1],
                                          order_data_i[j,4]))
      
    }
  }
  final_data_i = as.data.frame(final_data_i)
  final_data_i = as.data.frame(cbind(final_data_i[,c(1,3:10)],dummy(final_data_i$V2,sep="_")))
  TESCO_fc = final_data_i[,9]
  final_data_i = as.data.frame(final_data_i[,-9])
  colnames(final_data_i) = c("adjusted","adjusted_1","adjusted_2","adjusted_3","adjusted_4","adjusted_5","adjusted_6","adjusted_7","d1","d2","d3","d4","d5","d6","d7")
  RF <- randomForest(adjusted ~ ., data=final_data_i)
  predictRF <- predict(RF,newdata=final_data_i[,-1])
  SVM <- svm(adjusted~., data=final_data_i,kernel="radial",cost=2,gamma=1)
  predictSVM = predict(SVM,newdata=final_data_i[,-1])
  measureRF[i] = mean(abs(predictRF-final_data_i$adjusted))
  measureTESCO[i] = mean(abs(TESCO_fc-final_data_i$adjusted))
  measureSVM[i] = mean(abs(predictSVM-final_data_i$adjusted))
  }
}

ERF <- mean(na.omit(measureRF))
ET <- mean(na.omit(measureTESCO))
ESVM <- mean(na.omit(measureSVM))
