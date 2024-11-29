function p = points_on_rim(c_landmark, n_landmark, r_landmark, num_points)

% Compute points on the rim circle, in Planet Ref Fr computed from CNav inputs
RotoTransMat1=zeros(1,4);
RotoTransMat2=zeros(1,4);
RotoTransMat3=zeros(1,4);
primx=zeros(num_points);
primy=zeros(num_points);
primz=zeros(num_points);

for i=1:num_points
    primx(i)= r_landmark*cos((360/num_points)/180*pi*(i-1));
    primy(i)= r_landmark*sin((360/num_points)/180*pi*(i-1));
    primz(i)= 0;
end

if (n_landmark(2) ~= 0)    
    x(1)=0.5;  % Arbitrary Choice
    x(3)=x(1)/(1+(n_landmark(3)/n_landmark(2))^2)*(-n_landmark(1)*n_landmark(3)/n_landmark(2)^2-...
    sqrt((n_landmark(1)*n_landmark(3)/n_landmark(2)^2)^2-((n_landmark(1)/n_landmark(2))^2+1-1/x(1)^2)*(1+(n_landmark(3)/n_landmark(2))^2)));
    x(2)=(-x(1)*n_landmark(1)-x(3)*n_landmark(3))/n_landmark(2);
   else if (n_landmark(3) ~= 0)
    x(1)=0.5;  % Arbitrary Choice           
    x(2)=x(1)/(1+(n_landmark(2)/n_landmark(3))^2)*(-n_landmark(1)*n_landmark(2)/n_landmark(3)^2-...
    sqrt((n_landmark(1)*n_landmark(2)/n_landmark(3)^2)^2-((n_landmark(1)/n_landmark(3))^2+1-1/x(1)^2)*(1+(n_landmark(2)/n_landmark(3))^2)));
    x(3)=(-x(1)*n_landmark(1)-x(2)*n_landmark(2))/n_landmark(3);  
   else
      x=[1 0 0];
   end
end

y(1)=n_landmark(2)*x(3)-n_landmark(3)*x(2);
y(2)=n_landmark(3)*x(1)-n_landmark(1)*x(3);
y(3)=n_landmark(1)*x(2)-n_landmark(2)*x(1);


RotoTransMat1=[x(1) y(1) n_landmark(1) c_landmark(1)]; 
RotoTransMat2=[x(2) y(2) n_landmark(2) c_landmark(2)]; 
RotoTransMat3=[x(3) y(3) n_landmark(3) c_landmark(3)];

for i=1:num_points
    Vect=[primx(i); primy(i); primz(i); 1];
    p(1,i)=RotoTransMat1*Vect;
    p(2,i)=RotoTransMat2*Vect;
    p(3,i)=RotoTransMat3*Vect;
end    

end
