clc
clear all
close all
table = readmatrix('datos.csv');
Tam=length(table);

bol=0;

while bol==0
    prompt = "1. Argentina \n2. Bolivia \n3. Venezuela \n\nSELECIONE UN PAIS: ";
    pais = input(prompt);
    if pais ~= 1 && pais ~= 2 && pais ~= 3
    disp('El pais ingresado no es valido')
    else
        bol=1;
    end
end

for i=1:Tam
   inflacion(i)=table(pais+1,i);
end
for i=1:Tam
   anios(i)=table(1,i);
end
Media = mean(inflacion);
Desvio = std(inflacion);
x= [inflacion(Tam-3) inflacion(Tam-2) inflacion(Tam-1) inflacion(Tam)];
Media_4UD=mean(inflacion(end-3:end));
Desvio_4UD=std(inflacion(end-3:end));
xData = linspace(anios(1),anios(Tam),Tam);

figure(1)
bar(xData,inflacion)
title('Inflacion en % por año')
xlabel ('Años')
ylabel ('% POrcentaje de inflacion por año')
%set(gca,'XTick',[startDate:endDate])
%set(gca,'YTick',[min(Casos_Nuevos):10:max(Casos_Nuevos)])
grid on

a=0;
for i = 1:Tam
   a=a+inflacion(i);
   x2(i)=a;
end


%%%%%%%% FIG 2:
figure(2)
bar(xData,x2)
title('Inflacion en % por año')
xlabel ('Años')
ylabel ('% POrcentaje de inflacion por año')
%set(gca,'XTick',[startDate:endDate])
%set(gca,'YTick',[min(Casos_Nuevos):10:max(Casos_Nuevos)])
grid on



%%%%%%%% FIG 3: 

figure (3)
plot(xData,x2)
hold on
stairs(xData,x2,'r','LineWidth',2)
title('Dist. Acumulada Inflación por año')
xlabel ('Años')
ylabel ('Acumulada')

grid on
hold off
x3=x2/max(x2);


%%%%%%%% FIG 4: 
figure (4)
plot(xData,x3)
hold on
stairs(xData,x3,'g','LineWidth',2)

title('Dist. Acumulada Inflación por año')
xlabel ('Años')
ylabel ('Acumulada')
grid on
hold off


Retardo_Novo=inflacion;
x1=find(Retardo_Novo==0);
Retardo_Novo(x1)=[];
Retardo_RMS = abs(Retardo_Novo);

p=sort((inflacion')); 
maximo=max(p);
minimo=min(p);
Vrms=[minimo:0.002:maximo maximo];
tam_p=size(p);
percentual=(1/tam_p(2));
k=1;
for i=Vrms
      dist_cum_retRMS(k)=length(find(p<=i))*percentual;
      k=k+1;
end

dist_cum_retRMS=dist_cum_retRMS/max(dist_cum_retRMS);


% CDF LogNormal
Param_Logn= mle(Retardo_RMS,'distribution','logn');
L = cdf('logn',Vrms,Param_Logn(1), Param_Logn(2));

% CDF Normal
Param_Norm= mle(Retardo_RMS,'distribution','norm');
norm = cdf('norm',Vrms,Param_Norm(1), Param_Norm(2));

% CDF Weibull
Param_Weibull = mle(Retardo_RMS,'distribution','Weibull');
w=cdf('Weibull',Vrms,Param_Weibull(1),Param_Weibull(2));

% CDF Nakagami Teórica
param_Nakagami = mle(Retardo_RMS,'distribution','nakagami');
n = cdf('nakagami',Vrms,param_Nakagami(1),param_Nakagami(2));

% CDF Rice Teórica
Param_Rice = mle(Retardo_RMS,'distribution','rician');
r = cdf('rician',Vrms,Param_Rice(1),Param_Rice(2));

% CDF Rayleigh Teórica
Param_Rayl = mle(Retardo_RMS,'distribution','rayl');
ry = cdf('rayl',Vrms,Param_Rayl(1));

figure (5)
stairs(Vrms,dist_cum_retRMS)
hold on 
% plot all the distributions and put a label
plot(Vrms,L,'r','LineWidth',2)
plot(Vrms,norm,'g','LineWidth',2)
plot(Vrms,w,'k','LineWidth',2)
plot(Vrms,n,'b','LineWidth',2)
plot(Vrms,r,'m','LineWidth',2)
plot(Vrms,ry,'c','LineWidth',2)
legend('Empirical','Lognormal','Normal','Weibull','Nakagami','Rice','Rayleigh')
title('Distribución de Retardo')
xlabel ('Retardo (s)')
ylabel ('CDF')
grid on
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%R) Dados Empíricos
Dados_Emp = dist_cum_retRMS';
%1) CDF LogNormal Teórica
LogN=L';
%2) CDF Normal Teórica
NormT=norm';
%3) CDF Weibull Teórica
WeiT=w';
%4) CDF Nakagami Teórica
NakT=n';
%5) CDF Rice Teórica
RicT=r';
%6) CDF Rayleigh Teórica
RayT=ry';

% % % % % % % % % % % % % % Meida do  Error

ME_LogN = mean(LogN-Dados_Emp);
ME_NormT = mean(NormT-Dados_Emp);
ME_WeiT = mean(WeiT-Dados_Emp);
ME_NakT = mean(NakT-Dados_Emp);
ME_RicT = mean(RicT-Dados_Emp);
ME_RayT = mean(RayT-Dados_Emp);

% % % % % % % % % % % % Desvio Padrão do Erro

Tam_DE = size(Dados_Emp);
Sigma_LogN = sqrt(sum(((LogN-Dados_Emp)-ME_LogN).^2)/(Tam_DE(1)-1));
% SL=std(LogN-Dados_Emp);
Sigma_NormT = sqrt(sum(((NormT-Dados_Emp)-ME_NormT).^2)/(Tam_DE(1)-1));
% SN=std(NormT-Dados_Emp);
Sigma_WeiT = sqrt(sum(((WeiT-Dados_Emp)-ME_WeiT).^2)/(Tam_DE(1)-1));
% SW=std(WeiT-Dados_Emp);
Sigma_NakT = sqrt(sum(((NakT-Dados_Emp)-ME_NakT).^2)/(Tam_DE(1)-1));
% SN1=std(NakT-Dados_Emp);
Sigma_RicT = sqrt(sum(((RicT-Dados_Emp)-ME_RicT).^2)/(Tam_DE(1)-1));
% SR=std(RicT-Dados_Emp);
Sigma_RayT = sqrt(sum(((RayT-Dados_Emp)-ME_RayT).^2)/(Tam_DE(1)-1));
% SR1=std(RayT-Dados_Emp);

% % % % % % % % % % % % Root Mean Squared Error

ErrorCuadraticoLogaritmicaNormal = sqrt(mean((Dados_Emp - LogN).^2)); 
% RMSD_LogN_L = sqrt((ME_LogN).^2+(Sigma_LogN).^2);
ErrorCuadraticoNormal = sqrt(mean((Dados_Emp - NormT).^2));
% RMSD_NormT_L  = sqrt((ME_NormT).^2+(Sigma_NormT).^2);
ErrorCuadraticoWeilbull = sqrt(mean((Dados_Emp - WeiT).^2));
% RMSD_WeiT_L = sqrt((ME_WeiT).^2+(Sigma_WeiT).^2);
ErrorCuadraticoNakagami = sqrt(mean((Dados_Emp - NakT).^2));
% RMSD_NakT_L = sqrt((ME_NakT).^2+(Sigma_NakT).^2);
ErrorCuadraticoRice = sqrt(mean((Dados_Emp - RicT).^2)); 
% RMSD_RicT_L = sqrt((ME_RicT).^2+(Sigma_RicT).^2);
ErrorCuadraticorayLeight = sqrt(mean((Dados_Emp - RayT).^2));
% RMSD_RayT_L = sqrt((ME_RayT).^2+(Sigma_RayT).^2);

