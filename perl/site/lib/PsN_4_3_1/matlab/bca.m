function [lower,upper]=bca(estimate,bootstat,jackstat,low,up)
% Ber�knar BCA-konfidensintervall enligt Efron
% Anrop [lower,upper]=bca(estimate,bootstat,jackstat,low,up)
% Parametrar:
% estimate=originalestimat
% bootstat=matris av bootstrapestimat
% jackstat=matris av jackknifeestimat
% low=undre konfidensgrad i procent
% up=�vre konfidensgrad i procent
% Output:
% lower=undre konfidensgr�ns
% upper=�vre konfidensgr�ns

% Ber�kning av hj�lpstorheten zhat 
[a,b]=size(bootstat);
antal=sum(bootstat<=(ones(a,1)*estimate))
zhat=norminv(antal/a);
% Ber�kning av hj�lpstorheten ahat
%[nrow,ncol]=size(x);
%if nrow<ncol
%	x=x';
%	nrow=ncol ;
%end
%% Jackknife estimates in s (Lasse)
%for j=1:nrow
%	if j==1
%		values=[2:nrow];
%	elseif j==nrow
%		values=[1:nrow-1];
%	else	
%		values=[1:j-1, j+1:nrow];
%	end
%	s(j,:)=feval(fun,x(values,:));
%end
s=jackstat;
mn=mean(s); 				% theta_hat_dot (Lasse)
[b c]=size(s);
d=s-ones(b,1)*mn;
sum2=sum(d.^2);				% - t�ljare
sum3=sum(d.^3);				% del av n�mnare
ahat=-sum3./(6*(sum2.^(1.5)));
% Ber�kning av korrigerade konfidensgrader enligt Efron 
n=norminv(low/100);
alfa1=100*normcdf(zhat+(zhat+n)./(1-ahat.*(zhat+n)));
n=norminv(up/100);
alfa2=100*normcdf(zhat+(zhat+n)./(1-ahat.*(zhat+n)));
% Ber�kning av konfidensgr�nser med percentilmetoden
lower=diag(prctile(bootstat,alfa1))';
upper=diag(prctile(bootstat,alfa2))';
