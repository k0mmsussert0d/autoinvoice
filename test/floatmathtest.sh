#!/bin/bash

function floatMath {
    echo $(bc <<< "scale=$2; $1")
}

read dupa
cipa=$(floatMath $dupa 2)
echo $cipa
