function [nnIndex, nnDist, distCompCount] = bbTreeSearch(vec, bbTree, allData)
%bbTreeSearch: BB (branch-and-bound) tree search for 1 nearest neighbor
%
%	Usage:
%		[nnIndex, nnDist, distCompCount] = bbTreeSearch(vec, bbTree, allData)
%
%	Description:
%		[nnIndex, nnDist, distCompCount] = bbTreeSearch(vec, bbTree, allData) returns the 1 nearest neighbor via BB (branch-and-bound) tree search
%			vec: test input vector
%			bbTree: tree structure generated by bbTreeGen, with the following fields:
%				bbTree(i).mean: mean vector of a tree node
%				bbTree(i).radius: radius vector of a tree node
%				bbTree(i).child: indices of children for a non-terminal node
%				bbTree(i).dataIndex: indices of data for a terminal node
%				bbTree(i).dist2mean: distance to mean of a terminal node
%			allData: all sample data points
%			nnIndex: index of the nearest neighbor
%			nnDist: distance to the nearest neighbor
%			distCompCount: no. of distance computation
%
%	Example:
%		dim=2;
%		dataNum=1000;
%		testNum=100;
%		data=rand(dim, dataNum);
%		testData=rand(dim, testNum);
%		clusterNum=3;
%		level=4;
%		plotOpt=1;
%		bbTree=bbTreeGen(data, clusterNum, level, plotOpt);
%		for i=1:testNum
%			[nnIndex(i), nnDist(i), distCompCount(i)] = bbTreeSearch(testData(:,i), bbTree, data);
%		end
%		distMat=distPairwise(data, testData);
%		[minValue, minIndex]=min(distMat);
%		fprintf('isequal(nnIndex, minIndex)=%d\n', isequal(nnIndex, minIndex));
%		plot(distCompCount, '.-');
%		xlabel('Test case indices'); ylabel('Distance computation count');
%		title(sprintf('Average number of distance computation = %f\n', mean(distCompCount)));
%
%	See also bbTreeGen.

%	Category: Nearest Neighbor Search
%	Roger Jang, 20000114, 20110206

if nargin<1, selfdemo; return; end

global DISTCOMPCOUNT	% No. of distance computation
DISTCOMPCOUNT=0;		% No. of distance computation
[nnIndex, nnDist]=treeSearch(vec, bbTree, 1, allData);
distCompCount=DISTCOMPCOUNT;

% ====== Search a tree
function [nnIndex, nnDist]=treeSearch(vec, tree, nodeIndex, allData, nnIndex, nnDist)
if nargin<5, nnIndex=[]; end
if nargin<6, nnDist=inf; end

dist2mean=distance(vec, tree(nodeIndex).mean);
% ====== According to rule 1
if dist2mean>=nnDist+tree(nodeIndex).radius
%	fprintf('Node %g is skipped.\n', nodeIndex);
	return;
end
% ====== Recursion into the child nodes
for i=1:length(tree(nodeIndex).child)
	childNodeIndex=tree(nodeIndex).child(i);
	[nnIndex, nnDist]=treeSearch(vec, tree, childNodeIndex, allData, nnIndex, nnDist);
end
% ====== Check data points within terminal nodes
if isempty(tree(nodeIndex).child)
	% ====== Check each data item
	dataIndex=tree(nodeIndex).dataIndex;
	for i=1:length(dataIndex),
		% ====== According to rule 2
		if dist2mean<nnDist+tree(nodeIndex).dist2mean(i),
			temp=distance(vec, allData(:, dataIndex(i)));
			if temp<nnDist
				nnDist=temp;
				nnIndex=dataIndex(i);
			end
		end
	end
end

% ====== Definition of distance() subfunction
function out=distance(vec1, vec2)
global DISTCOMPCOUNT
out=norm(vec1-vec2);
DISTCOMPCOUNT=DISTCOMPCOUNT+1;

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);