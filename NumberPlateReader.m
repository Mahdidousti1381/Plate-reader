clc
close all;
clear;
load leterdigit.mat;
load blueplate.mat;
% reading the video and saving as frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
video = VideoReader("L90.mp4","CurrentTime",0);
frames = cell(1, floor(video.FrameRate));
for i = 1:video.NumFrames
    frames(1, i) = {read(video, i)};
end
%choosing best frame 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ro4=[0 0 0];
blueflag=0;
%this for loop contains a part of the code of module 2 which finds the blue part of numberplate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for t=1:3
pic=cell2mat(frames(1,floor(video.NumFrames*t/4)));
totalLetters=size(data,2);
graypic=rgb2gray(pic);
threshold = graythresh(graypic);
binpic =~im2bw(graypic,threshold);
bluearea = false(size(pic,1), size(pic,2));
for i=1:size(pic,1)
   for j=1:size(pic,2)
        if pic(i,j,1)<70 && pic(i,j,2)<70 && pic(i,j,3)>110 
            bluearea(i,j)=1;
        elseif pic(i,j,1)<100 && pic(i,j,2)<100 && pic(i,j,3)>130 
            bluearea(i,j)=1;
         elseif pic(i,j,1)<110 && pic(i,j,2)<110 && pic(i,j,3)>200 
            bluearea(i,j)=1;
         end
   end
end
bluearea=imresize(bluearea,[800 600]);
bluearea = bwareaopen(bluearea,40);
bluearea = bluearea - bwareaopen(bluearea,1500);
[Lp,Me]=bwlabel(bluearea);      
ro2=[];
ro3=[];
improp=regionprops(Lp ,'BoundingBox','Area');
if Me==0
blueflag=1;
end
    
    for m=1:Me
            [row,column] = find(Lp==m);
            X=bluearea(min(row):max(row),min(column):max(column));
            X=imresize(X,[42,24]);
             for k=1:3   
                ro2(1,k)=abs(corr2(bdata{1,k},X));              
             end
             ro2
           ro3(1,m)=mean(ro2);
    end    
    if blueflag==1
        ro3=0;
    end
     
    [MAXro3,position3]=max(ro3);
    ro4(1,t)=max(ro3);
end
    [MAXro4,position4]=max(ro4);
    position4
MAXro4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Module 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%now we want to crop the car from the chosen frame of the video 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pic=cell2mat(frames(1,floor(video.NumFrames*position4/4)));
totalLetters=size(data,2);
graypic=rgb2gray(pic);
threshold = graythresh(graypic);
binpic =~im2bw(graypic,threshold);
% finding blue areas 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bluearea = false(size(pic,1), size(pic,2));
blueflag=0;
for i=1:size(pic,1)
   for j=1:size(pic,2)
        if pic(i,j,1)<70 && pic(i,j,2)<70 && pic(i,j,3)>110 
            bluearea(i,j)=1;
        elseif pic(i,j,1)<100 && pic(i,j,2)<100 && pic(i,j,3)>130 
            bluearea(i,j)=1;
         elseif pic(i,j,1)<110 && pic(i,j,2)<110 && pic(i,j,3)>200 
            bluearea(i,j)=1;
         end
   end
end
%choosing blue part of numberplate between all found blueareas
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bluearea=imresize(bluearea,[800 600]);
figure(1)
bluearea = bwareaopen(bluearea,40);
bluearea = bluearea - bwareaopen(bluearea,1500);
subplot(1,2,1)
imshow(bluearea)
title('All found blue objects');
[Lp,Me]=bwlabel(bluearea);      
ro2=[];
ro3=[];
improp=regionprops(Lp ,'BoundingBox','Area');
hold on;
    for n=1:size(improp,1)
      rectangle('Position',improp(n).BoundingBox,'EdgeColor','g','LineWidth',0.5)
    end
hold off;
    for m=1:Me
            [row,column] = find(Lp==m);
            X=bluearea(min(row):max(row),min(column):max(column));
            X=imresize(X,[42,24]);
             for k=1:3   
                ro2(1,k)=abs(corr2(bdata{1,k},X));              
             end
             ro2
           ro3(1,m)=mean(ro2);
    end        
    [MAXro3,position3]=max(ro3);
     position3
MAXro3
subplot(1,2,2)
imshow(Lp==position3);
title('Blue area of numberplate');
%extracting location of bluepart of numberplate in the whole picture
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[rowB,colB] = find(Lp==position3);
blueplate=[min(rowB):max(rowB),min(colB):max(colB)];
imlength=max(colB)-min(colB);
imwidth=max(rowB)-min(rowB);
blueprop=regionprops(blueplate ,'BoundingBox','Area');
imlength
imwidth
%cropping numberplate area from the binerized picture of car 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%limitting and converting length and width of bluepart of plate  to a specific number area  
if imlength<=7
    imlength=imlength*2.8;
elseif imlength>7 && imlength<=9
imlength=imlength*2.2;
elseif imlength>9 && imlength<=13
imlength=imlength*1.51;
elseif imlength>13 && imlength<15
imlength=imlength*1.3;
elseif imlength>20 && imlength<=25
    imlength=imlength*0.8;
elseif imlength>25
    imlength=imlength*0.6;
end
if imwidth<=5
    imwidth=imwidth*9;
elseif imwidth>5 && imwidth<=10
    imwidth=imwidth*5;
elseif imwidth>10 && imwidth<=20
    imwidth=imwidth*2.5;
elseif imwidth>20 && imwidth<=30
imwidht=imwidth*2; 
elseif imwidth>=52 && imwidth<=62
    imwidth=imwidth*0.8;
elseif imwidth>=63
    imwidth=imwidth*0.6;
end
figure(2)
pic=imresize(pic,[800, 600]);
subplot(1,2,1)
imshow(pic);
title(['Chosen frame of video']);
subplot(1,2,2)
JP=imcrop(pic,[min(colB)-imlength*9 max(rowB)-imwidth*5 imlength*28 imwidth*10]);
imshow(JP);
title(['The car cropped from chosen frame of video']);
figure(3)
binpic=imresize(binpic,[800, 600]);
subplot(1,2,1)
imcropped=imcrop(pic,[min(colB)-imlength max(rowB)-imwidth*2 imlength*15 imwidth*3]);
imshow(imcropped);
title('Numberplate Area');
subplot(1,2,2)
binimcropped=imcrop(binpic,[min(colB)-imlength max(rowB)-imwidth*2 imlength*15 imwidth*3]);
imshow(binimcropped);
title('Black and white Numberplate Area');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Module 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
picture=imresize(binimcropped,[300 500]);
% Removing the small objects and background from cropped image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4)
% picture = bwareaopen(picture,30); % removes all connected components (objects) that have fewer than 30 pixels from the binary image BW
picture = bwareaopen(picture,300); 
subplot(1,3,1)
imshow(picture);
title('Numberplate Area');
background=bwareaopen(picture,3500);
subplot(1,3,2)
imshow(background);
title('Background');
picture2=picture-background;
subplot(1,3,3)
imshow(picture2)
title(['Numbers of Numberplate']);
% Labeling connected components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(5)
imshow(picture2)
[L,Ne]=bwlabel(picture2);
propied=regionprops(L,'BoundingBox');
hold on
for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off
title('Detected Location of Numbers of in binery image');

% comparing binery picture with picture of numbers in data base 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(6)
m=size(propied);
final_output1=[];
final_output_L=[];
final_output2=[];
final_output3=[];
t=[];
file = fopen('number_Plate.txt', 'wt');
i = 0;
for n=1:Ne
    [r,c] = find(L==n);
    Y=picture2(min(r):max(r),min(c):max(c));
    imshow(Y)
    Y=imresize(Y,[24,42]);
    imshow(Y)
    pause(0.2)

    ro=zeros(1,totalLetters);
    for k=1:totalLetters   
        ro(k)=corr2(data{1,k},Y);
    end

    [MAXRO,pos]=max(ro);
    MAXRO
    if MAXRO>.58
        out=cell2mat(data(2,pos));   
             if(i<2)
                final_output1=[final_output1 ;  out];  
             end      

             if(i==2)
               final_output_L=[out];       
             end     

             if(i>2&& i<6)
                final_output2=[final_output2 ;  out];  
             end

             if(i>=6)
                final_output3=[final_output3 ;  out];      
             end  
             
           i=i+1;
    end
end                    
% Printing the plate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%s\n',final_output1);
fprintf(file,'%s\n',final_output_L);             
fprintf(file,'%s\n',final_output2);
fprintf(file,'%s',final_output3);
fclose(file);
winopen('number_Plate.txt')