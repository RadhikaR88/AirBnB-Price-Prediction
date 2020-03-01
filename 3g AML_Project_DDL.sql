create database aml;

drop table aml.airbnb;

create table aml.airbnb(
id bigint
,hostYear smallint
,hostResponseHours tinyint
,neighbourhoodCleansed varchar(50)
,neighbourhoodGroupCleansed varchar(50)
,accommodates tinyint
,bathrooms decimal(3,1)
,bedType varchar(15)
,bedrooms tinyint
,beds tinyint
,TV tinyint
,cancellationPolicy varchar(15)
,cleaningFee smallint
,extraPeople smallint
,guestsIncluded tinyint
,maximumNights smallint
,minimumNights smallint
,price mediumint
,propertyType varchar(50)
,roomType varchar(50)
,securityDeposit mediumint
,numberOfReviews int
,reviewScoresAccuracy tinyint
,reviewScoresCheckin tinyint
,reviewScoresCleanliness tinyint
,reviewScoresCommunication tinyint
,reviewScoresLocation tinyint
,reviewScoresRating tinyint
,reviewScoresValue tinyint
,reviewsperMonth decimal(10,2)
,checkIn24Hours boolean
,accessibleHeightToilet boolean
,airConditioning boolean
,BBQgrill boolean
,babyBath boolean
,babyMonitor boolean
,babySitterRecommendations boolean
,bathTub boolean
,bedLinens boolean
,breakfast boolean
,buzzerOrWirelessIntercom boolean
,cableTV boolean
,carbonMonoxideDetector boolean
,cats boolean
,changingTable boolean
,childrenBooksAndToys boolean
,childrenDinnerware boolean
,cleaningBeforeCheckout boolean
,coffeemaker boolean
,cookingBasics boolean
,crib boolean
,dishesAndSilverware boolean
,dishwasher boolean
,dogs boolean
,doorman boolean
,doormanEntry boolean
,dryer boolean
,elevator boolean
,essentials boolean
,extraPillowsBlankets boolean
,familyAndKidFriendly boolean
,fireExtinguisher boolean
,fireplaceGuards boolean
,firstAidKit boolean
,freeParkingOnPremises boolean
,freeParkingOnStreet boolean
,gameConsole boolean
,gardenOrBackyard boolean
,railsInShowerToilet boolean
,gym boolean
,hairdryer boolean
,hangers boolean
,heating boolean
,highchair boolean
,hottub boolean
,hotwater boolean
,indoorFireplace boolean
,internet boolean
,iron boolean
,keypad boolean
,kitchen boolean
,laptopFriendlyWorkspace boolean
,lockOnBedroomDoor boolean
,lockbox boolean
,longTermStaysAllowed boolean
,luggageDropOffAllowed boolean
,microwave boolean
,otherPets boolean
,outletCovers boolean
,oven boolean
,packNPlayTravelCrib boolean
,pathToEntranceLitAtNight boolean
,patioOrBalcony boolean
,petsAllowed boolean
,petsLiveOnThisProperty boolean
,pool boolean
,privateBathroom boolean
,privatEentrance boolean
,privateLivingRoom boolean
,refrigerator boolean
,shades boolean
,safetyCard boolean
,selfCheckIn boolean
,shampoo boolean
,smartlock boolean
,smokeDetector boolean
,smokingAllowed boolean
,stairGates boolean
,stepFreeaccess boolean
,stove boolean
,suitableForEvents boolean
,tableCornerGuards boolean
,washer boolean
,washerDryer boolean
,wheelchairAccessible boolean
,wideClearanceToBed boolean
,wideClearanceShowerToilet boolean
,wideDoorway boolean
,wideHallwayClearance boolean
,windowGuards boolean
,wirelessInternet boolean
,hosting_amenity_49 boolean
,hosting_amenity_50 boolean
,hostHasProfilePic boolean
,hostIdentityVerified boolean
,hostIsSuperhost boolean
,instantBookable boolean
,isLocationExact boolean
,requireGuestPhoneVerification boolean
,requireGuestProfilePicture boolean
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/final_project.csv' 
INTO TABLE aml.airbnb 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from aml.airbnb;

create user r_user@localhost identified with mysql_native_password BY 'r_password';
grant select on aml.* to r_user@localhost;