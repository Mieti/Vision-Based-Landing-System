function [filtered_landmarks] = filter_landmarks(input_landmarks, distance_threshold)
%     filtered_landmarks.num_landmarks = 0;
%     
%     k = 1;
%     for i = 1:input_landmarks.num_landmarks
%         object_one = [input_landmarks.clandmarkX(i); input_landmarks.clandmarkY(i); input_landmarks.clandmarkZ(i)];
%         
%         % for each landmark: check if the only one in a predefined area
%         close = false;
%         for j = 1:input_landmarks.num_landmarks
%            if i ~= j
%                object_two = [input_landmarks.clandmarkX(j); input_landmarks.clandmarkY(j); input_landmarks.clandmarkZ(j)];
%                distance = norm(object_one - object_two);
%                if distance < distance_threshold
%                    close = true;
%                    break;
%                end
%            end
%         end
%         
%         if close == true 
%             % Too close to another landmark, make it disappear
%         else
%             % OK, add it to the filtered landmarks struct
%             filtered_landmarks.clandmarkX(k) = object_one(1);
%             filtered_landmarks.clandmarkY(k) = object_one(2);
%             filtered_landmarks.clandmarkZ(k) = object_one(3);
%             filtered_landmarks.rlandmark(k) = input_landmarks.rlandmark(i);
%             filtered_landmarks.nlandmarkX(k) = input_landmarks.nlandmarkX(i);
%             filtered_landmarks.nlandmarkY(k) = input_landmarks.nlandmarkY(i);
%             filtered_landmarks.nlandmarkZ(k) = input_landmarks.nlandmarkZ(i);
%             filtered_landmarks.num_landmarks = k;
%             k = k + 1;
%         end
%     end
    
    
    
    filtered_landmarks.num_landmarks = input_landmarks.num_landmarks;
    for i=1:input_landmarks.num_landmarks
        object_one = [input_landmarks.clandmarkX(i); input_landmarks.clandmarkY(i); input_landmarks.clandmarkZ(i)];
        filtered_landmarks.clandmarkX(i) = object_one(1);
        filtered_landmarks.clandmarkY(i) = object_one(2);
        filtered_landmarks.clandmarkZ(i) = object_one(3);
        filtered_landmarks.rlandmark(i) = input_landmarks.rlandmark(i);
        filtered_landmarks.nlandmarkX(i) = input_landmarks.nlandmarkX(i);
        filtered_landmarks.nlandmarkY(i) = input_landmarks.nlandmarkY(i);
        filtered_landmarks.nlandmarkZ(i) = input_landmarks.nlandmarkZ(i);
    end
    
    while 1
        % identify element close to others
        close_element = false;
        index_close_element = -1;
        
        for i=1:filtered_landmarks.num_landmarks
            object_one = [filtered_landmarks.clandmarkX(i); filtered_landmarks.clandmarkY(i); filtered_landmarks.clandmarkZ(i)];
            % for each landmark: check if the only one in a predefined area
            for j = 1:filtered_landmarks.num_landmarks
               if i ~= j
                   object_two = [filtered_landmarks.clandmarkX(j); filtered_landmarks.clandmarkY(j); filtered_landmarks.clandmarkZ(j)];
                   distance = norm(object_one - object_two);
                   if distance < distance_threshold
                       close_element = true;
                       break;
                   end
               end
            end

            if close_element == true 
                % Too close to another landmark, make it disappear
                index_close_element = i;
                break;
            end  
        end
        
        if close_element == false
            % finish if every element is far from his neighbors
            break;
        else
            % delete close element
            last_index = filtered_landmarks.num_landmarks;
            
            tmp_var.clandmarkX = filtered_landmarks.clandmarkX(index_close_element);
            tmp_var.clandmarkY = filtered_landmarks.clandmarkY(index_close_element);
            tmp_var.clandmarkZ = filtered_landmarks.clandmarkZ(index_close_element);
            tmp_var.rlandmark = filtered_landmarks.rlandmark(index_close_element);
            tmp_var.nlandmarkX = filtered_landmarks.nlandmarkX(index_close_element);
            tmp_var.nlandmarkY = filtered_landmarks.nlandmarkY(index_close_element);
            tmp_var.nlandmarkZ = filtered_landmarks.nlandmarkZ(index_close_element);
            
            filtered_landmarks.clandmarkX(index_close_element) = filtered_landmarks.clandmarkX(last_index);
            filtered_landmarks.clandmarkY(index_close_element) = filtered_landmarks.clandmarkY(last_index);
            filtered_landmarks.clandmarkZ(index_close_element) = filtered_landmarks.clandmarkZ(last_index);
            filtered_landmarks.rlandmark(index_close_element) = filtered_landmarks.rlandmark(last_index);
            filtered_landmarks.nlandmarkX(index_close_element) = filtered_landmarks.nlandmarkX(last_index);
            filtered_landmarks.nlandmarkY(index_close_element) = filtered_landmarks.nlandmarkY(last_index);
            filtered_landmarks.nlandmarkZ(index_close_element) = filtered_landmarks.nlandmarkZ(last_index);
            
            filtered_landmarks.clandmarkX(last_index) = tmp_var.clandmarkX;
            filtered_landmarks.clandmarkY(last_index) = tmp_var.clandmarkY;
            filtered_landmarks.clandmarkZ(last_index) = tmp_var.clandmarkZ;
            filtered_landmarks.rlandmark(last_index) = tmp_var.rlandmark;
            filtered_landmarks.nlandmarkX(last_index) = tmp_var.nlandmarkX;
            filtered_landmarks.nlandmarkY(last_index) = tmp_var.nlandmarkY;
            filtered_landmarks.nlandmarkZ(last_index) = tmp_var.nlandmarkZ;
            
            filtered_landmarks.num_landmarks = filtered_landmarks.num_landmarks - 1;
        end
    end        
        
end

