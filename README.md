# ElementaryOS UpdateBase 19.04 Disco Dingo

<p><b> Descrição: </b></p>
<p>
    Este script foi criado para trocar a base do sistema Elementary OS 5.0
 mudando a plataforma do Ubuntu 18.04 para o Ubuntu 19.04.
</p>
 <p>
    Apesar de ter sido testado, toda e qualquer alteração no sistema pode
 causar danos e instabilidade no mesmo. Ao executar este script, você faz por
 sua conta e risco.
</p>
<p>
    O uso é recomendado apenas para pessoas que já possuem um conhecimento
 intermediário sobre os arquivos do sistema linux.
    Este codigo é livre para que você modifique conforme sua necessidade,
 podendo também redistribuir sua copia sem a necessidade da permissão do autor
 lembrando apenas de fazer mensão ao mesmo.
</p>

<br>

<p><b> Pré requisitos: </b></p>
<pre>
    Sistema Operacional: Elementary OS 5.0 Juno
    Usuário: root
</pre>

<br>

##### Com o usuário root execute o comando abaixo:
```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/clayton-pereira/eOS_UpdateBase19.04/master/UpdateBase.sh)"
```

<br>

<p><b> Atenção </b></p>
<p>
  Após a atualização da base de sistema, o software-properties fica inutilizável, se você precisar adicionar repositórios no sistema, terá que fazer manualmente pois o comando <b><i>add-apt-repository</i></b> não estará funcionando.<br>
Toda via será perguntado antes da atualização do sistema se deseja instalar os repositórios do <a href="https://github.com/elementary-tweaks/elementary-tweaks">elementary-tweaks</a> e <a href="https://flatpak.org/setup/elementary%20OS/">flatpak</a>.
    <br>
    Considere também que o suporte da versão 19.04 é de 9 meses e, se encerrará aproximadamente entre Dezembro de 2019 e Janeiro de 2020.
</p>
