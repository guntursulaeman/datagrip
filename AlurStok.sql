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


select sum(JumlahStok)
from ProdukRetailerStok
where IdProdukRetailer = 14624
order by CreatedAt desc
select *
from produkretailer
where IdRetailer = 'RT0000036779'

exec RecalculateStokAwalAkhirV11 14624, 0

begin tran
insert into ProdukRetailerStokCopy (Id, IdProdukRetailer, KodeTransaksiStok, StokAwal, JumlahStok, StokAkhir, TipeStok,
                                    Deskripsi, CreatedAt, CreatedBy, UpdatedAt, UpdatedBy, Catatan)
select Id,
       IdProdukRetailer,
       KodeTransaksiStok,
       StokAwal,
       JumlahStok,
       StokAkhir,
       TipeStok,
       Deskripsi,
       CreatedAt,
       CreatedBy,
       UpdatedAt,
       UpdatedBy,
       'backup karena ada selisih stokawal-stokakhir'
from ProdukRetailerStok
where IdProdukRetailer = 14624
  and id not in (select id from ProdukRetailerStokCopy where IdProdukRetailer = 14624)
order by Id
rollback

select distinct Catatan
from ProdukRetailerStokCopy

select sum(b.Qty) qty, a.KodeRetailer, a.IdKecamatan, IdProdukRetailer
from pkp a
         inner join PkpDetail b on a.Id = b.IdPkp
where Status = 'r'
  and (DocDate between '2022-08-01' and '2022-08-30')
  and KodeRetailer = 'RT0000050673'
group by a.KodeRetailer, a.IdKecamatan, IdProdukRetailer

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

;
with dataMutasiPkp as (select IdPenjualanProdukRetailer, sum(Qty) qtyMutasi
                       from penjualanprodukretailerpkp
                       group by IdPenjualanProdukRetailer)
select a.NoNota, TanggalNota, b.id, b.qty, c.qtyMutasi,a.Catatan
from penjualan a
         inner join PenjualanProdukRetailer b on a.Id = b.IdPenjualan
         inner join dataMutasiPkp c on b.Id = c.IdPenjualanProdukRetailer
where IdRetailer = 'RT0000038978'
  and b.Qty <> c.qtyMutasi



select c.KodeProduk, sum(d.Qty) qtymutasi
from penjualan a
         inner join penjualanprodukretailer b on a.Id = b.IdPenjualan
         inner join produkretailer c on b.IdProdukRetailer = c.Id
inner join dbo.PenjualanProdukRetailerPkp d on b.Id = d.IdPenjualanProdukRetailer
where a.IdRetailer = 'RT0000038978'
  and TanggalNota >= '2022-09-01'
group by c.KodeProduk

select KodeProduk, sum(b.Qty) qty,sum(b.Stok) stok
from pkp a
         inner join pkpdetail b on a.Id = b.IdPkp
         inner join ProdukRetailer c on b.IdProdukRetailer = c.Id
where DocDate >= '2022-09-01'
  and IdRetailer = 'RT0000038978' and a.Status = 'r'
group by KodeProduk

select b.* from pkp a
inner join pkpdetail b on a.Id = b.IdPkp
where KodeRetailer = 'RT0000038978' and KodeProdukRMS = 'UN46'
order by CreatedAt desc

select * from udfTableRetailerStokAwal('RT0000055104',9,2023)
select * from RetailerStok where IdRetailer = 'RT0000055104' and Bulan in (8,9,10)

select * from TPubersClaim where NoNota = 'STET91/C005YT' order by CreatedDate desc
select * from TPubersClaim where sts = 2 order by CreatedDate desc


declare @idRetailer   varchar(12) = 'RT0000088980'
declare @stockDate    datetime
declare @cutoffDate    datetime
declare @stockDateNew datetime
declare @bulan        int
declare @tahun        int
set @stockDate = getdate()
declare @loop int = 5

while @loop >= 0
    begin
        set @bulan = month(dateadd(month, @loop * -1, @stockDate))
        set @tahun = year(dateadd(month, @loop * -1, @stockDate))
        set @stockDateNew = dateadd(day, -1, dateadd(month, 1, datefromparts(@tahun, @bulan, 1)))
        declare retailerCursor cursor
            for select IdRetailer, TanggalStokAwal
                from RetailerRoles
                where IdRetailer = 'RT0000088980' and isF6Rekan = 1 and TanggalStokAwal<=@stockDateNew
        open retailerCursor
        fetch next from retailerCursor into @idRetailer,@cutoffDate
        while @@fetch_status = 0
            begin
                exec sprocCalculateStokv4 @idRetailer, @cutoffDate, @stockDateNew
                fetch next from retailerCursor into @idRetailer,@cutoffDate
            end
        close retailerCursor
        deallocate retailerCursor
        set @loop = @loop - 1
    end

    select * from udfTableRetailerStokAwal('RT0000035725',5,2023)

begin tran
delete from RetailerStok where IdRetailer = 'RT0000035725'
rollback

select * from RetailerStok where IdRetailer = 'RT0000088980' order by Tahun,Bulan