select Method,
       Host,
       path,
       RequestDate,
--        JSON_VALUE(RequestBody,'$.NoNota'),
--        JSON_VALUE(RequestBody,'$.NoTransaksi'),
--        substring(RequestBody, charindex('NoNota', RequestBody, 0), 23)      nonota,
--        substring(RequestBody, charindex('NoTransaksi', RequestBody, 0), 28) nonota,
       RequestBody,
       ResponseBody,
       StatusCode,
       AppVersion
from HttpLog
where Method = 'GET'
  and Path = '/Penjualan/ListNotaFileLocal'
  --and JSON_VALUE(RequestBody,'$.NoTransaksi') = 'STXL01/30001P'
  and RequestDate >= '2023-11-01'
  and Host = 'ipubers-dev.pupuk-indonesia.com'
order by RequestDate desc


with dataLinkLokal as
         (select a.NoNota,
                 a.IdRetailer,
                 b.NoNota     notaBatal,
                 a.TanggalNota,
                 a.TanggalNotaWIB,
                 prop.Nama as propinsi,
                 kab.Nama  as kabupaten,
                 kec.Nama  as kecamatan,
                 p.NamaPetani,
                 p.NIK,
                 r.Code,
                 r.Name    as NamaKios,
                 a.BuktiKtpBeda,
                 a.BuktiPenyaluranPetani
          from penjualan a
                   left join Petani p on a.IdPetani = p.Id
                   left join retailer r on r.code = a.IdRetailer
                   left join MasterKecamatan kec on kec.Id = r.IdKecamatan
                   left join MasterKabupaten kab on kab.Id = kec.IdKab
                   left join MasterPropinsi prop on prop.Id = kab.IdProp
                   left join penjualan b on a.NoNota = b.NoReferensi
          where a.BuktiKtpBeda not like 'https://%'
            and a.BuktiKtpBeda is not null
            --and a.IdRetailer = 'RT0000016437'
            and a.Status = 2
            and b.NoNota is null
            --and MONTH(a.TanggalNota) = 10
            and year(a.TanggalNota) = 2023),
     dataKiosAppversion22 as (select distinct CreatedBy
                              from RMS_Log.dbo.HttpLog
                              where AppVersion = 'Aren-2-2'
                                --and JSON_VALUE(RequestBody,'$.NoTransaksi') = 'STXL01/30001P'
                                and (RequestDate >= '2023-11-10' and RequestDate <= '2023-11-13 12:00')
                                and Host = 'ipubers.pupuk-indonesia.com')
select IdRetailer,
       count(NoNota)                                                                jmlLinkLocal,
       case when b.CreatedBy is not null then 'apps-updated' else 'not-updated' end isAppsUpdated
from dataLinkLokal a
         left join dataKiosAppversion22 b on a.Code = b.CreatedBy collate database_default
group by IdRetailer, case when b.CreatedBy is not null then 'apps-updated' else 'not-updated' end