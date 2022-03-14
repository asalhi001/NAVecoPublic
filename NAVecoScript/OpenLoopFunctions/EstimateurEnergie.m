function [EnergieFinal] = EstimateurEnergie(problem,VitesseRef,TorqRef)
            RPMwh  = 30*VitesseRef./(problem.data.Rw*pi);    % RPM de la roue
            RPM    = problem.data.Ig*RPMwh;     % RPM du moteur
            RPMopt = problem.data.maxRPM/3;            % 1/3 de RPM max
            u1opt  = (2/5)*problem.data.maxTorq;         % 2/5 du couple max
            
            if (problem.data.Tech(1)=='E'||problem.data.Tech(1)=='H') % Hibrido Pendiente
                effm = 0.9 - ((RPM-RPMopt).^2)*problem.data.Krpm - ((TorqRef-u1opt).^2)*problem.data.Ktorq;
                effr = 0.74 - ((RPM-RPMopt).^2)*problem.data.Krpm - ((abs(TorqRef)-u1opt).^2)*problem.data.Ktorq; 
            else
                effm = 0.5 - ((RPM-RPMopt).^2)*problem.data.Krpm - ((TorqRef-u1opt).^2)*problem.data.Ktorq;
                effr = 0 - ((RPM-RPMopt).^2)*problem.data.Krpm*0 - ((TorqRef-u1opt).^2)*problem.data.Ktorq*0;
            end
            
            eff=ones(size(TorqRef));
            
            for i=1:length(TorqRef)
                if(TorqRef(i)>0)
                    eff(i)=abs(1/effm(i));
                    %eff(i)=1/0.8;
                else
                    eff(i)=abs(effr(i));
                    %eff(i)=0.2;
                end
            end
            
%             PuissanceFinal = (TorqRef.*RPM*pi/30).*eff;
            PuissanceFinal = ((TorqRef/problem.data.Rw).*VitesseRef).*eff;
            EnergieFinal = cumtrapz(PuissanceFinal);        
            EnergieFinal = EnergieFinal/(3600); % Ws -> Wh 
end

