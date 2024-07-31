% schedule=[1工件号 2工序号  3机器号 4开工时间 5完工时间 6工厂号 7装配号 8属性(0加工/1装配)]
% if 8==1  schedule=[-1 -1 -1 4开工时间 5完工时间 -1 7装配号 8属性(1装配)]
function keypath_schedule = find_keypath_schedule(schedule, Cmax)
    Cmax_schedules = schedule(schedule(:, 5) == Cmax, :);
    this_schedule = Cmax_schedules(1, :);
    this_schedule_conmence_time = this_schedule(4);
    keypath_schedule = this_schedule;

    while (this_schedule_conmence_time > 0)

        schedule_end_eq_this_conmence = schedule(schedule(:, 5) == this_schedule_conmence_time, :);
        the_next_schedule = schedule_end_eq_this_conmence(randperm(size(schedule_end_eq_this_conmence, 1), 1), :);
        keypath_schedule = [the_next_schedule; keypath_schedule];
        this_schedule = the_next_schedule;
        this_schedule_conmence_time = this_schedule(4);

    end

end

% function [chromo,keypath_schedule]= search_key_path(schedule,Cmax,workpieceNum,machNum)
%     schedule=sortrows(schedule,4);
%     last_schedule_index=find(schedule(:,5)==Cmax);%选最后一个数的行数
%     last_schedule= last_schedule_index(randi(numel(last_schedule_index)));
%     temp_key_path_schedule=
%
% end

% function keypath_schedule=find_keypath_schedule(sch,Cmax)
% lastsch=find(sch(:,5)==Cmax);%选最后一个数的行数
% lastsch= lastsch(randi(numel(lastsch)));
% % lastsch= randi(find(lastsch==1));
% tempPath=[sch(lastsch,2),lastsch,sch(lastsch,1),sch(lastsch,3)];
% while length(lastsch)>=1
%     temp=find(sch(lastsch,4)==sch(:,5));%temp是临时的行数
%     if numel(temp)==1
%         lastsch=temp;
%     else        %如果同时有工件前序工件，机器前序工件，选工件前序（这样生成的块会少于选机器前序工件）
%         s_temp=temp(sch(temp,1)==sch(lastsch,1));
%         if isempty(s_temp)  %如果没有工件前序工序，选机器前序工件
%             temp=temp(sch(temp,2)==sch(lastsch,2));
%             lastsch=temp;
%         else
%         temp=s_temp;
%         lastsch=temp;
%         end
%     end
%         tempPath=[tempPath;[sch(temp,2),temp,sch(temp,1),sch(temp,3)]];
%         keyPath=flip(tempPath);
% keypath_schedule=sch(keyPath(:,2),:);
% end

%keypath【机器号，行号，工件号，工序号】
