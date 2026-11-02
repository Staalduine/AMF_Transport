import re, glob, sys
import pandas as pd
d = sys.argv[1]
m = []
for f in glob.glob(f"{d}/SCP*_2866*.out"):
    ctl = re.search(r"_(\d+)\.out", f)[1]
    for jid, rule, wc in re.findall(r"SLURM jobid (\d+) \(log: \S+/rule_(\w+)/([^/]+)/", open(f).read()):
        m.append((jid, rule, wc.split("_")[0], wc, ctl))
m = pd.DataFrame(m, columns=["jid","rule","plate","wc","ctl"]).drop_duplicates("jid")
s = pd.read_csv(f"{d}/sacct_raw.psv", sep="|", dtype=str)
s["base"] = s.JobID.str.split(".").str[0]
top = s[~s.JobID.str.contains(r"\.")].copy()
st0 = s[s.JobID.str.endswith(".0")].set_index("base")
def secs(t):
    if not isinstance(t,str) or not t: return float("nan")
    days = 0
    if "-" in t: dd, t = t.split("-"); days = int(dd)
    p = [float(x) for x in t.split(":")]
    while len(p) < 3: p.insert(0, 0)
    return days*86400 + p[0]*3600 + p[1]*60 + p[2]
def mem_gb(x):
    if not isinstance(x,str) or not x: return float("nan")
    u = x[-1]; v = float(x[:-1]) if u.isalpha() else float(x)
    return v * {"K":1/2**20,"M":1/1024,"G":1,"T":1024}.get(u, 1/2**30)
top = top.merge(m, left_on="JobID", right_on="jid", how="inner")
top["state"] = top.State.str.split().str[0]
top["elapsed_s"] = top.ElapsedRaw.astype(float)
top["submit"] = pd.to_datetime(top.Submit); top["start"] = pd.to_datetime(top.Start, errors="coerce")
top["wait_s"] = (top.start - top.submit).dt.total_seconds()
top["cpu_s"] = top.JobID.map(st0.TotalCPU).map(secs)
top["maxrss_gb"] = top.JobID.map(st0.MaxRSS).map(mem_gb)
top["cpus"] = top.AllocCPUS.astype(int); top["req_gb"] = top.ReqMem.map(mem_gb)
top["limit_s"] = top.Timelimit.map(secs)
top["cpu_eff"] = top.cpu_s / (top.elapsed_s * top.cpus)
top.drop(columns=["jid"]).to_csv(f"{d}/../scp_sacct_2026-10-29.tsv", sep="\t", index=False)
fin = top[top.state.isin(["COMPLETED"])]
print("STATES\n", pd.crosstab(top.plate, top.state, margins=True).to_string())
print("\nPARTITIONS\n", pd.crosstab(top.rule, top.Partition).to_string())
g = fin.groupby("rule").agg(n=("JobID","size"), cpus=("cpus","median"), req_gb=("req_gb","median"),
    lim_min=("limit_s", lambda x: x.median()/60), med_el_min=("elapsed_s", lambda x: x.median()/60),
    max_el_min=("elapsed_s", lambda x: x.max()/60), med_wait_min=("wait_s", lambda x: x.median()/60),
    p90_wait_min=("wait_s", lambda x: x.quantile(.9)/60),
    cpu_eff=("cpu_eff","median"), rss_med=("maxrss_gb","median"), rss_max=("maxrss_gb","max"), rss_n=("maxrss_gb","count"))
print("\nPER RULE (COMPLETED)\n", g.round(2).sort_values("med_el_min", ascending=False).to_string())
bad = top[~top.state.isin(["COMPLETED","RUNNING","PENDING"])]
print("\nNON-OK\n", bad.groupby(["plate","rule","state"]).size().to_string())
print("\nRUNNING/PENDING\n", pd.crosstab(top.rule, top.state).to_string())
