
#generate ssh keys
if [ ! -f "$HOME/.ssh/config" -a ! -f "$HOME/.ssh/hpcincloud" ]; then
    install -d -m 700 $HOME/.ssh
    ssh-keygen -t dsa -f $HOME/.ssh/hpcincloud -N '' -C "hpc cloud toolkit key" > /dev/null 2>&1
    cat $HOME/.ssh/hpcincloud.pub >> $HOME/.ssh/authorized_keys
    chmod 0600 $HOME/.ssh/authorized_keys

    echo "# Added on  `date +%Y-%m-%d 2>/dev/null` by hpc cloud toolkit" >> $HOME/.ssh/config
    echo "Host *" >> $HOME/.ssh/config
    echo "   IdentityFile ~/.ssh/hpcincloud" >> $HOME/.ssh/config
    echo "   StrictHostKeyChecking=no" >> $HOME/.ssh/config
    chmod 0600 $HOME/.ssh/config
fi
