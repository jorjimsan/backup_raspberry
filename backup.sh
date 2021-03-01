#!/bin/sh

SALIR=0
OPCION=0

while [ $SALIR -eq 0 ]; do
	sudo clear
	echo 'NOMBRE-FECHA\t\tDESCRIPCIÓN' > backup_avariable.log
	echo '-----------------------------------' >> backup_avariable.log
	if [ -f ./backup.log ];
        then
		while IFS=";" read -r nombre descripcion sha1sum
		do
        		if [ -f './'$nombre ];
        		then
	        	       	echo $nombre'\t'$descripcion >> backup_avariable.log
        		fi
		done < backup.log
	fi
	avariable=$(sudo cat backup_avariable.log | wc -l)
	echo "Menú:"
	echo "1) Ver Copias de Seguridad Disponibles"
	echo "2) Ver Información del Archivo Log"
	echo "3) Ver Discos Montados"
	echo "4) Desmontar Partición"
	echo "5) Crear Copia de Seguridad"
	echo "6) Comprimir Copia de Seguridad"
	echo "7) Descomprimir Copia de Seguridad"
	echo "8) Restaurar Copia de Seguridad"
	echo "9) Eliminar Copia de Seguridad"
	echo "q) Salir"
	echo "Opción seleccionada"
	read OPCION
	case $OPCION in
		1)
			clear
			sudo cat backup_avariable.log
			echo ""
                        echo "Pulse Intro para Continuar"
                        read INTRO;;
		2)
			clear
			echo 'NOMBRE-FECHA\t\tDESCRIPCIÓN\tSHA1SUM'
			echo '-----------------------------------------------'
                	if [ -f ./backup.log ];
                	then
				while IFS=";" read -r nombre2 descripcion2 sha1sum2
				do
					echo $nombre2'\t'$descripcion2'\t'$sha1sum2
        			done < backup.log
			fi
			echo ""
                        echo "Pulse Intro para Continuar"
                        read INTRO;;
		3)
			clear
			sudo df -h
			echo ""
			echo "Pulse Intro para Continuar"
			read INTRO;;
		4)
			clear
			sudo df -h
			echo ""
			echo "Introduzca Partición a Desmontar (sin terminar en /)"
			read DESM
			sudo umount $DESM
			echo ""
			sudo df -h
              		echo ""
		        echo "Pulse Intro para Continuar"
                        read INTRO;;
		5)
			clear
			sudo fdisk -l
			echo ""
			echo "Elige Unidad Origen (sin terminar en /)"
			read ORG
			fecha=$(date +%Y%m%d%H%M)
			sudo dd if=$ORG | pv | sudo dd of='./backup'$fecha'.img' bs=1M
			echo ""
			echo "Pulse Intro para Realizar Comprobación"
			read INTRO
                        sum1=$(sudo sha1sum './backup'$fecha'.img' | cut -d " " -f 1)
			echo $sum1
			sum2=$(sudo sha1sum $ORG | cut -d " " -f 1)
			echo $sum2
			if [ $sum1 = $sum2 ];
			then
				echo "La suma de comprobación es CORRECTA"
	                        echo "Elige una Descripción para la Copia de Seguridad"
         	               	read DESCR
                	        if [ -f ./backup.log ];
                        	then
                                	index=$(echo $(($(sudo cat backup.log | wc -l)-2)))
                                	echo 'backup'$fecha'.img;'$DESCR';'$sum1 >> backup.log
                        	else
                                	echo 'backup'$fecha'.img;'$DESCR';'$sum1 > backup.log
                        	fi
                        else
				echo "La suma de comprobación NO es correcta"
				echo "Intentelo de Nuevo"
				sudo rm -rf './backup'$fecha'.img'
			fi
			echo ""
                        echo "Pulse Intro para Continuar"
                        read INTRO;;
       		6)
			clear
			if [ $avariable -gt 2 ];
			then
				sudo cat backup_avariable.log
				echo ""
				echo "Elige Backup a Comprimir (sin extensión)"
                        	read BACKUP
                        	echo "Elige Carpeta Destino (terminada en /)"
                        	read DIRDEST
				sudo tar -czvf $DIRDEST$BACKUP'.tar.gz' './'$BACKUP'.img'
				FIN=0
				while [ $FIN -eq 0 ]; do
        				read -p "¿Quieres Borrar la Imagen Original? (s/n)" yn
        				case $yn in
                				s)
                       	 				echo "Borrando la Imagen Original"
                        				sudo rm -rf './'$BACKUP'.img'
                        				FIN=1;;
                				n)
                        				FIN=1;;
               					*)
                        				echo "Tienes que Elijir s o n";;
        				esac
				done
			else
				echo "No hay Copias de Seguridad Disponibles para Comprimir"
			fi
			echo ""
			echo "Pulse Intro para Continuar"
                        read INTRO;;
		7)
			clear
			echo "Directorio de Archivo Comprimido (terminada en /)"
			read DIRORG
			sudo ls -la $DIRORG
			echo ""
			echo "Elige Backup a Descomprimir (sin extensión)"
			read BACKUP
			sudo tar -xvf $DIRORG$BACKUP'.tar.gz' -C ./
                      	echo "Pulse Intro para Realizar Comprobación"
                        read INTRO
			sum3=$(sudo sha1sum './'$BACKUP'.img')
                        echo $sum3
                        sum4=$(sudo cat backup.log | grep $BACKUP | cut -d ";" -f 3)
                        echo $sum4
                        if [ $sum3 = $sum4 ];
                        then
                                echo "La suma de comprobación es CORRECTA"
                        else
                                echo "La suma de comprobación NO es correcta"
                                echo "Intentelo de Nuevo"
                                sudo rm -rf './'$BACKUP'.img'
                        fi
                        echo ""
                        echo "Pulse Intro para Continuar"
                        read INTRO;;
		8)
                        clear
                        if [ $avariable -gt 2 ];
                        then
				sudo fdisk -l
				echo ""
				echo "Elige Unidad Destino (sin terminar en /)"
				read DEST
				sudo cat backup_avariable.log
				echo ""
				echo "Elige Copia de Seguridad a Restuarar (sin extensión)"
				read BACKUP
				sudo dd if='./'$BACKUP'.img' | pv | sudo dd of=$DEST bs=1M
	                        echo ""
        	                echo "Pulse Intro para Realizar Comprobación"
                	        read INTRO
				sum5=$(sudo sha1sum './backup'$fecha'.img' | cut -d " " -f 1)
                       		echo $sum5
                        	sum6=$(sudo sha1sum $DEST | cut -d " " -f 1)
                        	echo $sum6
                        	if [ $sum5 == $sum6 ];
                        	then
                                	echo "La suma de comprobación es CORRECTA"
	                                FIN=0
        	                        while [ $FIN -eq 0 ]; do
                	                        read -p "¿Quieres Borrar la Imagen Original? (s/n)" yn
                        	                case $yn in
                                	                s)
                                        	                echo "Borrando la Imagen Original"
                                                	        sudo rm -rf './'$BACKUP'.img'
                                                        	FIN=1;;
     	        	                                n)
        	                                                FIN=1;;
                        	                        *)
                                	                        echo "Tienes que Elijir s o n";;
                                        	esac
                                	done
                                else
                                	echo "La suma de comprobación NO es correcta"
                                	echo "Intentelo de Nuevo"
                                fi
			else
				echo "No hay Copias de Seguridad Disponibles para Restaurar"
			fi
			echo ""
                        echo "Pulse Intro para Continuar"
                        read INTRO;;
		9)
                        clear
                        if [ $avariable -gt 2 ];
                        then
                                sudo cat backup_avariable.log
                                echo ""
                                echo "Elige Copia de Seguridad que quiere Eliminar (sin extensión)"
                                read BACKUP
                                echo "Borrando la Imagen Original"
                                sudo rm -rf './'$BACKUP'.img'
                        else
                                echo "No hay Copias de Seguridad Disponibles para Eliminar"
                        fi
                        echo ""
                        echo "Pulse Intro para Continuar"
                        read INTRO;;
		q)
			clear
			SALIR=1;;
		*)
			clear
			echo "Opcion No Válida"
                        echo "Pulse Intro para Continua"
                        read INTRO;;
	esac
done
