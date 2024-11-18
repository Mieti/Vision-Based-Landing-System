craterList = readtable("CameraShot" + ".csv");
figure(1)
for i=1:length(craterList.PosX)
       xc(i) = craterList.PosX(i);
       yc(i) = craterList.PosY(i);
       r(i) = craterList.Diameter(i)/2;
       theta = linspace(0,2*pi);
      
       x = r(i)*cos(theta) + xc(i);
       y = r(i)*sin(theta) + yc(i);
       plot(x,y);
       hold on;  
end
    
