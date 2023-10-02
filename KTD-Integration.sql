select *
from BSIBurekolAktivasi
where NIK = '1101025004580001'
select *
from BSIBurekol
where NIK = '1101024107740029'
select *
from BsiKiosKartan

--cek alokasi sebelum dari table burekolBsi
select *
from dbo.udfMigRdkkUnpivotFromBurekol('1101024106810001', 2022, 'RT0000012888') a
         right join ProdukRetailer b on a.produk = b.KodeProduk and a.KodeKios = b.IdRetailer
where JenisProduk = 1
  and b.IdRetailer = 'RT0000012888'

exec sprocCreateRdkkFromBurekol 'RT0000012888', 2022, '101024106810001', '-', '-', 0

select a.CreatedAt,
       HargaJual,
       IdProdukRetailer,
       KodeProduk,
       a.IdRetailer,
       NamaPetani,
       NamaProduk,
       nik,
       NoNota,
       Qty,
       sisakuota = (select SisaAlokasi
                    from udfTableRdkkByRetailerNikYear(year(a.TanggalNota), a.idretailer, d.nik, a.createdat,
                                                       b.idprodukretailer)),
       NoReferensi,
       a.Status,
       TanggalNota
from penjualan a
         inner join Penjualanprodukretailer b on a.Id = b.IdPenjualan and JenisPenjualan = 1
         inner join produkretailer c on b.IdProdukRetailer = c.Id and c.JenisProduk = 1
         inner join petani d on a.IdPetani = d.Id and StatusPetani = 1
         inner join BsiKiosKartan e on a.IdRetailer = e.KodeKios and e.Status = 1
order by a.status, a.id, CreatedAt, b.Id

select a.CreatedAt,
       HargaJual,
       IdProdukRetailer,
       KodeProduk,
       a.IdRetailer,
       NamaPetani,
       NamaProduk,
       nik,
       NoNota,
       Qty,
       sisakuota = (select SisaAlokasi
                    from udfTableRdkkByRetailerNikYear(year(a.TanggalNota), a.idretailer, d.nik, a.createdat,
                                                       b.idprodukretailer)),
       NoReferensi,
       a.Status,
       TanggalNota
from penjualan a
         inner join Penjualanprodukretailer b on a.Id = b.IdPenjualan and JenisPenjualan = 1
         inner join produkretailer c on b.IdProdukRetailer = c.Id and c.JenisProduk = 1
         inner join petani d on a.IdPetani = d.Id and StatusPetani = 1
         inner join BsiKiosKartan e on a.IdRetailer = e.KodeKios and e.Status = 1
     --where (a.createdat>=@cutOffDate and a.createdat<dateadd(day ,1,@cutOffDate))
order by a.status, a.id, CreatedAt, b.Id


--query upload settlment
select a.CreatedAt,
       HargaJual,
       IdProdukRetailer,
       KodeProduk,
       a.IdRetailer,
       NamaPetani,
       NamaProduk,
       nik,
       NoNota,
       Qty,
       sisakuota = (select SisaAlokasi
                    from udfTableRdkkByRetailerNikYear(year(a.TanggalNota), a.idretailer, d.nik, a.createdat,
                                                       b.idprodukretailer)),
       NoReferensi,
       a.Status,
       TanggalNota
from penjualan a
         inner join Penjualanprodukretailer b on a.Id = b.IdPenjualan and JenisPenjualan = 1 and source = 8
         inner join produkretailer c on b.IdProdukRetailer = c.Id and c.JenisProduk = 1
         inner join petani d on a.IdPetani = d.Id and StatusPetani = 1
         inner join BsiKiosKartan e on a.IdRetailer = e.KodeKios and e.Status = 1
where (a.createdat >= '2022-11-10' and a.createdat < dateadd(day, 1, '2022-11-10'))
order by a.status, a.id, CreatedAt, b.Id


select *
from Penjualan
where NoNota in ('STLVS1/C00001', 'STLVS1/C00002', 'RTLVS1/C00002')

select *
from BSIBurekol
order by CreatedAt desc
select b.NamaPetani, b.KodeKios, a.*
from BSIBurekolAktivasi a
         inner join BSIBurekol b on a.nik = b.NIK
order by a.CreatedAt desc

select * from BSIBurekol where StatusRdkk = 0 and Status = 1 and Tahun = 2022 order by CreatedAt desc


--create rdkk by poktan by desa from burekol
declare @kodeRetailer varchar(20)
declare @namaPoktan varchar(200)
declare @kodeDesa varchar(20)
declare @ktp varchar(20)
declare @subSektor varchar(200)
declare @luasTanam float
declare @poktanid int
declare @tahun int
declare @komoditas varchar(100)
declare rdkk_cursor cursor
    --get data burekol yang akan dibuat RDKK nya
    for select KodeKios,
               KelompokTani,
               KodeDesa,
               NIK,
               subsektor='-',
               LuasTanam,
               PoktanId,
               Tahun,
               Komoditas
        from BSIBurekol
        where StatusRdkk = 0
          and Status = 1
          and Tipe = 1
          and KodeKios = 'RT0000014196'
open rdkk_cursor
fetch next from rdkk_cursor into @kodeRetailer,@namaPoktan,@kodeDesa,@ktp,@subSektor,@luasTanam,@poktanid,@tahun,@komoditas

while @@fetch_status = 0
    begin
        exec sprocCreateRdkkFromBurekolByKomoditasV11 @kodeRetailer, @tahun, @ktp, @namaPoktan, @subSektor, @luasTanam,
             @poktanid,
             @kodeDesa
        fetch next from rdkk_cursor into @kodeRetailer,@namaPoktan,@kodeDesa,@ktp,@subSektor,@luasTanam,@poktanid,@tahun,@komoditas
    end;
close rdkk_cursor
deallocate rdkk_cursor;
----------------------------------

select *
from Petani
where NIK = '1106040107730246'

select KodeKios, count(*), Komoditas
from BSIBurekol
group by KodeKios, Komoditas
order by 2 desc

select *
from Petani
where NIK = '1108110107400094'
select *
from RDKKPetani
where IdPetani = 363792

select *
from udfTableRdkkByRetailerByYearByPoktanV11('RT0000012888', 2022)
where NIK = '1101010101910003'

select *
from udfTableRdkkByRetailerByYearByPoktanByKomoditas('RT0000016344', 2023)
where StatusRdkkPetani = 1
select *
from JenisKomoditi

begin tran
    update RDKKPetani
    set Status = 1
    from rdkk a
             inner join RDKKPetani b on a.Id = b.IdRDKK
             inner join RDKKProduk c on b.Id = c.IdRDKKPetani
    where IdRetailer = 'RT0000014196'
      and b.Status = 0
      and Tahun = 2023
rollback

select *
from rdkk
where IdRetailer = 'RT0000014196'


select idrdkkpetani,
       IdRetailer,
       Kelurahan,
       Kecamatan,
       Subsektor,
       IdPetani,
       idproduk,
       b.PoktanId,
       KodeDesa,
       Tahun,
       b.NamaPoktan,
       b.Status       StatusRdkkPetani,
       sum(LuasTanam) LuasTanam,
       sum(mt)        MT,
       b.TipeTransaksi,
       b.PIN,
       c.Komoditas,
       c.IdKomoditas
from rdkk a
         inner join RDKKPetani b on a.Id = b.IdRDKK
         inner join RDKKProduk c on b.Id = c.IdRDKKPetani
where IdRetailer = 'RT0000016344'
  and b.Status = 1
  and Tahun = 2023
group by idrdkkpetani, IdRetailer, Kelurahan, Kecamatan, Subsektor, IdPetani, idproduk, b.PoktanId, b.KodeDesa,
         b.Status, b.NamaPoktan, Tahun, b.PIN, b.TipeTransaksi, c.Komoditas, c.IdKomoditas

select *
from RDKKPetani
where Id = 1154890
select *
from Petani
where id = 466801

select *
from udfTableRdkkByRetailerByYearByPoktanByKomoditas('RT0000016686', 2023)
select *
from AspNetUsers
where UserName = 'RT0000034393'

exec sprocTableRdkkByRetailerByYearByPoktanV12 'RT0000016686', 2023


select *
from Petani
where id = 465416
begin tran
    update petani
    set StatusPetani = 1
    from rdkk a
             inner join rdkkpetani b on a.Id = b.IdRDKK
             inner join petani c on b.IdPetani = c.Id
    where IdRetailer = 'RT0000014196'
      and Tahun = 2023
rollback

select *
from AspNetUsers
where UserName = 'RT0000016344'
select *
from ProdukRetailer
where IdRetailer = 'RT0000016344'
select *
from udfTableRdkkByRetailerByYearByPoktanV11('RT0000014196', 2023)

begin tran
    update Produk
    set StatusProduk = 0
    where JenisProduk = 1 --and IdRetailer in (select distinct KodeKios from BSIBurekol)
      and KodeProduk in ('ASZA', 'ORGR', 'ORCR', 'SP36')
rollback

select tahun, SUM(UreaMT1 + UreaMT2 + UreaMT3) UN46, SUM(NPKMT1 + NPKMT2 + NPKMT3)
from _migrdkk2023
where KodePIHCPengecer = 'RT0000053126'
group by tahun

select * from BSIBurekol where NIK = '1113020101930004' and Tahun = 2023
select * from RetailerRoles where isAllowMultiLogin = 0

declare @cutOffDate datetime = '2023-03-08'
;with dataIdPetani as (
                            select distinct IdPetani, nik, KodeKios from BSIBurekol where tahun = year(@cutOffDate) and Status = 1
                        ),
                                dataPenjualan as (
                                    select id,
                                        IdRetailer,
                                        NoNota,
                                        TanggalNota,
                                        IdPetani,
                                        CreatedAt,
                                        PoktanId,
                                        KomoditiId,
                                        KodeDesa,
                                        NoReferensi,
                                        Status
                                    from penjualan
                                    where (createdat >= @cutOffDate and createdat < dateadd(day, 1, @cutOffDate))
                                    and Source = 8
                                    and JenisPenjualan = 1
                                )
                        select          a.CreatedAt,
                                        HargaJual,
                                        IdProdukRetailer,
                                        KodeProduk,
                                        a.IdRetailer,
                                        NamaPetani,
                                        NamaProduk,
                                        d.nik,
                                        NoNota,
                                        Qty,
                            sisakuota = (select SisaAlokasi
                                            from udfTableRdkkByRetailerNikYearPoktanKomoditasDate(
                                                    year(a.TanggalNota),
                                                    a.idretailer,
                                                    d.nik,
                                                    a.createdat,
                                                    a.poktanId,
                                                    a.KomoditiId,
                                                    a.kodeDesa,
                                                    1
                                                )
                                            where idProdukRetailer = b.idprodukretailer),
                                        NoReferensi,
                                        a.Status,
                                        TanggalNota,
                                        a.poktanId,
                                        f.Nama as Komoditas,
                                        a.kodeDesa,
                                        g.IdPetani
                        from dataPenjualan a
                                    inner join Penjualanprodukretailer b on a.Id = b.IdPenjualan
                                    inner join produkretailer c on b.IdProdukRetailer = c.Id and c.JenisProduk = 1
                                    inner join petani d on a.IdPetani = d.Id and StatusPetani = 1
                                    inner join BsiKiosKartan e on a.IdRetailer = e.KodeKios and e.Status = 1
                                    inner join JenisKomoditi f on a.KomoditiId = f.Id
                                    inner join dataIdPetani g on d.NIK = g.NIK and a.IdRetailer = g.KodeKios
                        where (a.createdat >= @cutOffDate and a.createdat < dateadd(day, 1, @cutOffDate))
                        order by a.status, a.id, CreatedAt, b.Id

select * from Penjualan where Source = 8 order by TanggalNota desc
select * from penjualan