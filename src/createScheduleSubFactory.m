%生成一个染色体的时间表
%解码，生成时间表
function schedule = createScheduleSubFactory(changeData, chromo, workpieceNum, machNum)
    lengthNum = size(chromo, 2);
    schedule = zeros(lengthNum, 5);
    workpieceProcessId = zeros(1, workpieceNum);
    workpieceCanStartTime = zeros(1, workpieceNum);

    for i = 1:lengthNum
        workpieceId = chromo(i);
        workpieceProcessId(workpieceId) = workpieceProcessId(workpieceId) + 1;
        machId = changeData(workpieceId, 2 * workpieceProcessId(workpieceId) - 1);
        workpieceSpeedTime = changeData(workpieceId, 2 * workpieceProcessId(workpieceId));
        newSchedule = schedule(schedule(:, 3) == machId, :);
        isInsert = 0;

        if size(newSchedule, 1) == 0 %空的 直接安排 % % 应当讨论是否是共建的第一道工序
            % workpieceStartTime=0;
            % isInsert=1;
            if workpieceProcessId(workpieceId) == 1 % % %
                workpieceStartTime = 0;
                isInsert = 1;
            else % % % % % % % % % % %error???????????????????????
                workpieceStartTime = workpieceCanStartTime(1, workpieceId);
                isInsert = 1;
            end

        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            newSchedule = sortrows(newSchedule, 4); %排序一下

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if newSchedule(1, 4) >= workpieceCanStartTime(workpieceId) + workpieceSpeedTime %有安排了 就先看第一行
                workpieceStartTime = workpieceCanStartTime(workpieceId);
                isInsert = 1;
            end

            if isInsert == 0 %从第二行开始遍历

                for j = 2:size(newSchedule) %下行注释 间隔时间要大于用时，间隔结束时间要大于工件的拟完工时间

                    if newSchedule(j, 4) - newSchedule(j - 1, 5) >= workpieceSpeedTime

                        if newSchedule(j, 4) >= workpieceCanStartTime(workpieceId) + workpieceSpeedTime
                            %workpieceSpeedTime=max(workpieceCanStartTime(workpieceId),newSchedule(j-1,5));
                            workpieceStartTime = max(workpieceCanStartTime(workpieceId), newSchedule(j - 1, 5));
                            isInsert = 1;
                            break;
                        end

                    end

                end

            end

            if isInsert == 0 %遍历完了都没插入 直接插入在最后
                workpieceStartTime = max(workpieceCanStartTime(workpieceId), newSchedule(end, 5));
            end

        end

        %在此已经完成插入了，要更新各个表单
        workpieceCanStartTime(workpieceId) = workpieceStartTime + workpieceSpeedTime; %更新结束时间表
        workpieceEndTime = workpieceStartTime + workpieceSpeedTime;
        schedule(i, :) = [workpieceId, workpieceProcessId(workpieceId), machId, workpieceStartTime, workpieceEndTime];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %schedule=sortrows(schedule,4);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

end

% function schedule = createSchedule(changeData,chromo,workpieceNum,machNum)
%     lengthNum=size(chromo,2);
%     schedule=zeros(lengthNum,5);
%     workpieceProcessId=zeros(1,workpieceNum);
%     workpieceCanStartTime=zeros(1,workpieceNum);
%     machCanStartTime=zeros(1,machNum);
%     for i=1:lengthNum
%         workpieceId=chromo(i);
%         workpieceProcessId(workpieceId)=workpieceProcessId(workpieceId)+1;
%         machId=changeData(workpieceId,2*workpieceProcessId(workpieceId)-1);
%         workpieceSpeedTime=changeData(workpieceId,2*workpieceProcessId(workpieceId));
%
%
%
%         thisWorkpieceJobCanStartTime=workpieceCanStartTime(workpieceId);
%         thisWorkpieceMachCanStartTime=machCanStartTime(machId);
%         workpieceStartTime=max(thisWorkpieceJobCanStartTime,thisWorkpieceMachCanStartTime);
%
%
%         %在此已经完成插入了，要更新各个表单
%         workpieceCanStartTime(workpieceId)=workpieceStartTime+workpieceSpeedTime; %更新结束时间表
%         machCanStartTime(machId)=workpieceStartTime+workpieceSpeedTime;
%         workpieceEndTime=workpieceStartTime+workpieceSpeedTime;
%         schedule(i,:)=[workpieceId,workpieceProcessId(workpieceId),machId,workpieceStartTime,workpieceEndTime];
%     end
% end
