#!/bin/python3

import subprocess
import pandas as pd
import matplotlib.pyplot as plt
import math

def main():
    output = subprocess.run(['matlab', '-nodisplay', '-nodesktop', '-nosplash', '-r',
                             'runProNEVA US_Temp.txt'],
                            check=True, stdout=subprocess.PIPE, universal_newlines=True)

    print(output.stdout)
    plot()


def plot():
    # Read CSV file into DataFrame df
    df_observations = pd.read_csv('US_Temp.txt', header=None, delimiter="\n")
    df_rl95 = pd.read_csv('Results/NonStationaryAnalysis/RL95.csv', header=None, delimiter=",")
    df_rl05 = pd.read_csv('Results/NonStationaryAnalysis/RL05.csv', header=None, delimiter=",")
    df_rl50 = pd.read_csv('Results/NonStationaryAnalysis/RL50.csv', header=None, delimiter=",")
    df_rlm = pd.read_csv('Results/NonStationaryAnalysis/RLm.csv', header=None, delimiter=",")
    df_log10TT = pd.read_csv('Results/NonStationaryAnalysis/log10TT.csv', header=None, delimiter="\n")
    df_TT = pd.read_csv('Results/NonStationaryAnalysis/TT.csv', header=None, delimiter="\n")
    df_Tx = pd.read_csv('Results/NonStationaryAnalysis/Tx.csv', header=None, delimiter=",")
    df_fx = pd.read_csv('Results/NonStationaryAnalysis/fx.csv', header=None, delimiter=",")

    x = sorted(df_observations[0].tolist())
    print(df_Tx.iloc[0].tolist())

    log10TT = df_log10TT[0].tolist()
    log10Tx = [math.log10(x) for x in df_Tx.iloc[0].tolist()]

    plt.scatter(log10Tx, x, label="observations")

    plt.plot(log10TT, df_rl95[0].tolist(), "-", label="RL95")
    plt.plot(log10TT, df_rl05[0].tolist(), "-", label="RL05")
    plt.plot(log10TT, df_rl50[0].tolist(), "--", label="RL50")
    plt.plot(log10TT, df_rlm[0].tolist(), "-.", label="Median")

    #plt.xscale("log", base=10)
    plt.legend()
    plt.show()


if __name__ == "__main__":
    plot()
