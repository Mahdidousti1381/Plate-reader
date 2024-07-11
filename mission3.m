
clc
close all;
clear;
load leterdigit.mat;
totalLetters=size(data,2);
% SELECTING THE TEST DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[file,path]=uigetfile({'*.jpg;*.bmp;*.png;*.tif'},'Choose an image');
s=[path,file];
picture=imread(s);
figure
subplot(1,2,1)
imshow(picture)
picture=imresize(picture,[300 500]);
subplot(1,2,2)
imshow(picture)
3

%RGB2GRAY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
picture=rgb2gray(picture);
figure
subplot(1,2,1)
imshow(picture)

% THRESHOLDIG and CONVERSION TO A BINARY IMAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold = graythresh(picture);
picture =~im2bw(picture,threshold);
subplot(1,2,2)
imshow(picture)

% Removing the small objects and background
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
% picture = bwareaopen(picture,30); % removes all connected components (objects) that have fewer than 30 pixels from the binary image BW
picture = bwareaopen(picture,600); 
subplot(1,3,1)
imshow(picture)
background=bwareaopen(picture,5000);
subplot(1,3,2)
imshow(background)
picture2=picture-background;
subplot(1,3,3)
imshow(picture2)
% picture2=bwareaopen(picture2,200);
% subplot(1,4,4)
% imshow(picture2)
% Labeling connected components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
imshow(picture2)
[L,Ne]=bwlabel(picture2);
propied=regionprops(L,'BoundingBox');
hold on
for n=1:size(propied,1)
    rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off
% Decision Making
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
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
    if MAXRO>.45
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