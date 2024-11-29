function [landmarks] = generate_landmarks( ...
    DistXMax, DistYMax, DistZMax, NormXMax, NormYMax, num_landmarks, ...
    RadLMMin, RadLMMax)
%GENERATE_LANDMARKS function

    % Landmarks struct
    Cat1.num_landmarks = num_landmarks;
    landmark_rand_values = rand(7, Cat1.num_landmarks);

    for i_landmark = 1:Cat1.num_landmarks
        Cat1.ilandmark(i_landmark) = i_landmark;
        Cat1.clandmarkX(i_landmark) = DistXMax*2*(landmark_rand_values(1,i_landmark)-0.5);
        Cat1.clandmarkY(i_landmark) = DistYMax*2*(landmark_rand_values(2,i_landmark)-0.5);
        Cat1.clandmarkZ(i_landmark) = DistZMax*2*(landmark_rand_values(3,i_landmark)-0.5);
        Cat1.rlandmark(i_landmark) = (RadLMMax-RadLMMin)*landmark_rand_values(4,i_landmark)+RadLMMin;
        landmarkX = 2*NormXMax*(landmark_rand_values(5,i_landmark)-0.5);
        landmarkY = 2*NormYMax*(landmark_rand_values(6,i_landmark)-0.5);
        landmarkZ = landmark_rand_values(7,i_landmark);
        normlandmark = sqrt(landmarkX^2+landmarkY^2+landmarkZ^2);
        Cat1.nlandmarkX(i_landmark) = landmarkX/normlandmark;
        Cat1.nlandmarkY(i_landmark) = landmarkY/normlandmark;
        Cat1.nlandmarkZ(i_landmark) = landmarkZ/normlandmark;
        
    end

    landmarks = Cat1;

end