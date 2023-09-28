declare @idRetailer varchar(12)
declare @stockDate  datetime
set @stockDate = getdate()

declare retailerCursor cursor
    for select UserName
        from TPubersAuth
        where status = 3
open retailerCursor
fetch next from retailerCursor into @idRetailer
while @@fetch_status = 0
    begin
        exec sprocCalculateStokv3 @idRetailer, '2022-09-01', '2022-12-31'
        fetch next from retailerCursor into @idRetailer
    end
close retailerCursor
deallocate retailerCursor

select *
from ProdukRetailer
where id = 15245
--------------------------------------------------------------------------

exec sprocCalculateStokv31 'RT0000038965', '2022-09-01', '2022-12-31'
exec sprocCalculateStokv3WithKec 'RT0000036758', '2022-09-01', '2022-12-31', '517104'
select *
from RetailerStokCopy
where IdRetailer = 'RT0000038965'
  and Bulan = 12

select *
from RetailerStok
where IdRetailer = 'RT0000036758'
  and IdKecamatan = '517102'
order by Bulan, IdKecamatan

select *
from MasterKecamatan
where id in ('517104', '517102')

select sum(b.Qty) qty, a.KodeRetailer, a.IdKecamatan, IdProdukRetailer
from pkp a
         inner join PkpDetail b on a.Id = b.IdPkp
where Status = 'r'
  and (DocDate between '2022-08-01' and '2022-08-30')
  and KodeRetailer = 'RT0000050673'
group by a.KodeRetailer, a.IdKecamatan, IdProdukRetailer

select *
from RetailerStok
where IdRetailer = 'RT0000050673'
  and Bulan = 8

select a.IdRetailer, left(KodeDesa, 6) idKecamatan, b.IdProdukRetailer, sum(Qty) qty
from penjualan a
         inner join penjualanprodukretailer b on a.Id = b.IdPenjualan
where a.IdRetailer = 'RT0000050673'
  and JenisPenjualan = '1'
  and (TanggalNota between '2022-10-01' and '2022-10-30')
group by IdProdukRetailer, a.IdRetailer, left(KodeDesa, 6), b.IdProdukRetailer

select id,
       idretailer,
       idkecamatan,
       idprodukretailer,
       bulan,
       tahun,
       stokawal,
       stokakhir,
       catatan
from RetailerStok
where IdRetailer = 'RT0000050673'
  and Bulan = month(8)
  and Tahun = 2022

select a.KodeRetailer, a.IdKecamatan, IdProdukRetailer, sum(Qty) Qty
from pkp a
         inner join PkpDetail b on a.Id = b.IdPkp
where Status = 'r'
  and (DocDate between '2022-08-01' and '2022-09-30')
  and KodeRetailer = 'RT0000050673'
group by a.KodeRetailer, a.IdKecamatan, IdProdukRetailer

--=====================================================================================

select b.KodeProduk,
       Bulan,
       Tahun,
       sum(StokAwal)   stokawal,
       sum(Penebusan)  penebusan,
       sum(Penyaluran) penyaluran,
       sum(StokAkhir)  stokakhir
from RetailerStokCopy a
         inner join produkretailer b on a.IdProdukRetailer = b.Id
where a.IdRetailer <> 'PT0000065722'
group by b.KodeProduk, Bulan, Tahun
order by Tahun, Bulan

exec sprocTableRetailerStok 'RT0000036758', '2023-05-16'

select datefromparts(year(getdate()), month(getdate()), 1),
       dateadd(day, -1, datefromparts(year(getdate()), month(getdate()), 1))

select *
from RetailerRoles
where IdRetailer = 'RT0000087983'

declare @idRetailer   varchar(12)
declare @stockDate    datetime
declare @stockDateNew datetime
declare @bulan        int
declare @tahun        int
set @stockDate = getdate()
declare @loop int = 2

while @loop >= 0
    begin
        set @bulan = month(dateadd(month, @loop * -1, @stockDate))
        set @tahun = year(dateadd(month, @loop * -1, @stockDate))
        set @stockDateNew = dateadd(day, -1, dateadd(month, 1, datefromparts(@tahun, @bulan, 1)))
        declare retailerCursor cursor
            for select IdRetailer
                from RetailerRoles
                where isF6Rekan = 1
                  and IdRetailer = 'RT0000087983'
        open retailerCursor
        fetch next from retailerCursor into @idRetailer
        while @@fetch_status = 0
            begin
                exec sprocCalculateStokv3 @idRetailer, '2022-09-01', @stockDateNew
                fetch next from retailerCursor into @idRetailer
            end
        close retailerCursor
        deallocate retailerCursor

        exec sprocCalculateStokv3WithKec 'RT0000036758', '2022-09-01', @stockDate, '517104'
        exec sprocCalculateStokv3WithKec 'RT0000036758', '2022-09-01', @stockDate, '517102'
        set @loop = @loop - 1
    end