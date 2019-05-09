#!/bin/bash
IMPORT=$(qsub import.script)
qsub -W depend=afterok:$IMPORT core_metrics.script
qsub -W depend=afterok:$IMPORT visualizations.script
