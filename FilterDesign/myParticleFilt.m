function [estimateStates] = myParticleFilt(states,ESS,particleNumber)
%MYPARTICLEFILT ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
estimateStates = ones(length(states(:,1)),length(states));
dim = floor(length(states(:,1))/2);
particleNumber = dim * particleNumber;
stateNum = length(states);
microStateIndex = 1:1:dim;
microStateIndex = microStateIndex * 2 - 1;
microState = zeros(2,1);
oldState = zeros(2,1);
microStateWeight = zeros(2,1);
observedValue = zeros(2,1);
states = stateConvTime(states);
particleArray = zeros(dim*2,particleNumber/dim);
defaultWeight = 1/(particleNumber/dim);
particleWeight = ones(1,particleNumber/dim)*defaultWeight;
for stateIndex = 1:stateNum
    for particleIndex = 1:length(particleWeight)
        for dimIndex = 1:dim
            if stateIndex ~= 1
                oldState = particleArray(microStateIndex(dimIndex):microStateIndex(dimIndex)+1,particleIndex);
            end
            observedValue = states(microStateIndex(dimIndex):microStateIndex(dimIndex)+1,stateIndex);
            if stateIndex == 1
                %����͎������g
                microState = observedValue;
            else
                %2��ڈȍ~�̓V�X�e���������ɏ]��
                microState = systemEq(oldState) + systemNoiseReturn();
            end
            randomMicroState = observeSignal(microState);
            noise = observedValue - randomMicroState;
            particleWeight(particleIndex) = particleWeight(particleIndex) + likelihoodObservation(noise);
            particleArray(microStateIndex(dimIndex):microStateIndex(dimIndex)+1,particleIndex) = randomMicroState;
        end
    end
    %�d�݂̐��K������
    particleWeight = exp(particleWeight);
    cumsumWeight = cumsum(particleWeight);
    if cumsumWeight(end) ~= 0
        particleWeight = particleWeight / cumsumWeight(end);
        cumsumWeight = cumsumWeight / cumsumWeight(end);
    else
        particleWeight = ones(1,length(particleWeight))*defaultWeight;
        cumsumWeight = (1:1:length(particleWeight))* defaultWeight;
    end
    %���T���v�����O
    curESS = 1/(particleWeight*particleWeight');
    if curESS < ESS
        randomNum = rand(1)/length(particleWeight);
        samplingWeightBar = (0:1:length(particleWeight)-1)*defaultWeight;
        samplingWeightBar = samplingWeightBar + randomNum;
        samplingSourcePoint = 1;
        copyOfParticleArray =  particleArray;
        for particleIndex = 1 : length(particleWeight)
            while(samplingWeightBar(particleIndex)> cumsumWeight(samplingSourcePoint))
                samplingSourcePoint = samplingSourcePoint + 1;
            end
            particleArray(:,particleIndex) = copyOfParticleArray(:,samplingSourcePoint);
            particleWeight(particleIndex) = defaultWeight;
        end
    end
    %��Ԃ����߂�
    estimateStates(:,stateIndex) = weightedAve(particleArray,particleWeight);
    a = 1;
end
end

