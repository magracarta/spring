<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%
response.setHeader("Access-Control-Allow-Origin","*");
%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<script>
function openReportPanelDynamic(){
	openReportPanel($('#report_path').val(), $('#data_url').val());
}
</script>
<body>
<form id="main_form" name="main_form" enctype="multipart/form-data">
	<!-- contents 전체 영역 -->
	<div class="content-wrap">
		<div class="content-box">
			<!-- 메인 타이틀 -->
			<div class="main-title"></div>
			<!-- /메인 타이틀 -->
			<div class="contents" style="width: 100%; float: left;">
				<!-- 기본 -->
				<table class="table-border">
					<h2>파라미터 조회 팝업</h2>
					<colgroup>
						<col width="160px">
						<col width="220px">
						<col width="400px">
						<col width="150px">
						<col width="*">
					</colgroup>
					<thead>
						<th>리포트명</th>
						<th>리포트경로</th>
						<th>요청경로</th>
						<th>기능버튼</th>
						<th>예시</th>
					</thead>
					<tbody>
						<tr>
							<td><label>테스트</label></td>
							<td><label>CLIP.crf</label></td>
							<td><label>test_seq=123&test_name=홍길동</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('CLIP.crf','test_seq=123&test_name=홍길동');">테스트</button></td>
							<td><label>openReportPanel('CLIP.crf','/test/test0101?test_seq=123');</label></td>
						</tr>
<!-- 						<tr> -->
<!-- 							<td colspan="4"><label>고객</label></td> -->
<!-- 						</tr> -->
<!-- 						<tr> -->
<!-- 							<td><label>고객조회</label></td> -->
<!-- 							<td><label>cust/cust0102_01.crf</label></td> -->
<!-- 							<td><label>s_cust_name=건설</label></td> -->
<!-- 							<td><button type="button" class="btn btn-info" onclick="openReportPanel('cust/cust0102_01.crf','s_cust_name=건설');">고객조회</button></td> -->
<!-- 							<td><label>openReportPanel('cust/cust0102_01.crf','s_cust_name=건설');</label></td> -->
<!-- 						</tr> -->
						<tr>
							<td><label>거래원장</label></td>
							<td><label>cust/cust0106p01_01.crf</label></td>
							<td><label>s_cust_no=20140812205956205&s_start_dt=20200618&s_end_dt=20200918</label></td>
							<td>
								<button type="button" class="btn btn-info" onclick="openReportPanel('cust/cust0106p01_01.crf','s_cust_no=20140812205956205&s_start_dt=20200618&s_end_dt=20200918&prt_gubun=1');">거래원장(고객)</button>
								<button type="button" class="btn btn-info" style="margin-top:5px" onclick="openReportPanel('cust/cust0106p01_01.crf','s_cust_no=20140812205956205&s_start_dt=20200618&s_end_dt=20200918&prt_gubun=2');">거래원장(관리)</button>
							</td>
							<td><label>openReportPanel('cust/cust0106p01_01.crf','s_cust_no=20140812205956205&s_start_dt=20200618&s_end_dt=20200918');</label></td>
						</tr>
						<tr>
							<td><label>견적서관리>장비견적서</label></td>
							<td><label>cust/cust0107p01_01.crf</label></td>
							<td><label>rfq_no=RQ2020-00105-01&cust_no=20191010125342480</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('cust/cust0107p01_01.crf','rfq_no=RQ2020-00105-01&cust_no=20191010125342480');">장비견적서</button></td>
							<td><label>openReportPanel('cust/cust0107p01_01.crf','rfq_no=RQ2020-00105-01&cust_no=20191010125342480');</label></td>
						</tr>
						<tr>
							<td><label>견적서관리>수주견적서</label></td>
							<td><label>cust/cust0107p02_01.crf</label></td>
							<td><label>rfq_no=RQ2020-00101-01&cust_no=20191010125342480</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('cust/cust0107p02_01.crf','rfq_no=RQ2020-00101-01&cust_no=20191010125342480');">수주견적서</button></td>
							<td><label>openReportPanel('cust/cust0107p02_01.crf','rfq_no=RQ2020-00101-01&cust_no=20191010125342480');</label></td>
						</tr>
						<tr>
							<td><label>견적서관리>정비견적서</label></td>
							<td><label>cust/cust0107p03_01.crf</label></td>
							<td><label>rfq_no=2020-00093-01&cust_no=20190404144314951</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('cust/cust0107p03_01.crf','rfq_no=2020-00093-01&cust_no=20190404144314951');">정비견적서</button></td>
							<td><label>openReportPanel('cust/cust0107p03_01.crf','rfq_no=2020-00093-01&cust_no=20190404144314951');</label></td>
						</tr>
						<tr>
							<td><label>견적서관리>렌탈견적서</label></td>
							<td><label>cust/cust0107p04_01.crf</label></td>
							<td><label>rfq_no=2020-00097-02&cust_no=20120914101925161</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('cust/cust0107p04_01.crf','rfq_no=2020-00097-02&cust_no=20120914101925161');">렌탈견적서</button></td>
							<td><label>openReportPanel('cust/cust0107p04_01.crf','rfq_no=2020-00097-02&cust_no=20120914101925161');</label></td>
						</tr>
						<tr>
							<td><label>매출처리>거래명세표</label></td>
							<td><label>cust/cust0202p01_01.crf</label></td>
							<td><label>inout_doc_no=IN20200915-021</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('cust/cust0202p01_01.crf','inout_doc_no=IN20200915-021');">거래명세표</button></td>
							<td><label>openReportPanel('cust/cust0202p01_01.crf','inout_doc_no=IN20200915-021');</label></td>
						</tr>
						<tr>
							<td colspan="4"><label>마케팅</label></td>
						</tr>
						<tr>
							<td><label>출하의뢰서</label></td>
							<td><label>sale/sale0101p03_01.crf</label></td>
							<td><label>machine_doc_no=MC2020-0237-01</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('sale/sale0101p03_01.crf','machine_doc_no=MC2020-0237-01');">출하의뢰서</button></td>
							<td><label>openReportPanel('sale/sale0101p03_01.crf','machine_doc_no=MC2020-0237-01');</label></td>
						</tr>
						<tr>
							<td><label>양도증명서</label></td>
							<td><label>sale/sale0101p03_02.crf</label></td>
							<td><label>machine_doc_no=MC2020-0237-01</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('sale/sale0101p03_02.crf','machine_doc_no=MC2020-0237-01');">양도증명서</button></td>
							<td><label>openReportPanel('sale/sale0101p03_02.crf','machine_doc_no=MC2020-0237-01');</label></td>
						</tr>
						<tr>
							<td><label>장비인수증</label></td>
							<td><label>sale/sale0101p03_03.crf</label></td>
							<td><label>machine_doc_no=MC2020-0241-01</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('sale/sale0101p03_03.crf','machine_doc_no=MC2020-0241-01');">장비인수증</button></td>
							<td><label>openReportPanel('sale/sale0101p03_03.crf','machine_doc_no=MC2020-0241-01');</label></td>
						</tr>
						<tr>
							<td><label>STOCK출고의뢰서</label></td>
							<td><label>sale/sale0101p09_01.crf</label></td>
							<td><label>machine_doc_no=2020-0232-01</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('sale/sale0101p09_01.crf','machine_doc_no=2020-0232-01');">STOCK출고의뢰서</button></td>
							<td><label>openReportPanel('sale/sale0101p09_01.crf','machine_doc_no=2020-0232-01');</label></td>
						</tr>
						<tr>
							<td><label>기본지급품</label></td>
							<td><label>sale/sale0101p02_01.crf</label></td>
							<td><label>machine_plant_seq=272</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('sale/sale0101p02_01.crf','machine_plant_seq=272');">기본지급품</button></td>
							<td><label>openReportPanel('sale/sale0101p02_01.crf','machine_plant_seq=272');</label></td>
						</tr>
						<tr>
							<td><label>생산발주서</label></td>
							<td><label>sale/sale0201p01_01.crf</label></td>
							<td><label>machine_order_no=MO2020-0101</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('sale/sale0201p01_01.crf','machine_order_no=MO2020-0101');">생산발주서</button></td>
							<td><label>openReportPanel('sale/sale0201p01_01.crf','machine_order_no=MO2020-0101');</label></td>
						</tr>
						<tr>
							<td colspan="4"><label>부품</label></td>
						</tr>
						<tr>
							<td><label>부품이동처리</label></td>
							<td><label>part/part0202p01_01.crf</label></td>
							<td><label>part_trans_no=20190201-0002</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('part/part0202p01_01.crf','part_trans_no=20190201-0002');">부품이동처리</button></td>
							<td><label>openReportPanel('part/part0202p01_01.crf','part_trans_no=20190201-0002');</label></td>
						</tr>
						<tr>
							<td><label>매입처관리</label></td>
							<td><label>part/part0301_01.crf</label></td>
							<td><label>s_cust_name=건설</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('part/part0301_01.crf','s_cust_name=건설');">매입처관리</button></td>
							<td><label>openReportPanel('part/part0301_01.crf','s_cust_name=건설');</label></td>
						</tr>
						<tr>
							<td><label>부품발주서(한글)</label></td>
							<td><label>part/part0403p01_01.crf</label></td>
							<td><label>part_order_no=PO20190215-0148</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('part/part0403p01_01.crf','part_order_no=PO20190215-0148');">부품발주서(한글)</button></td>
							<td><label>openReportPanel('part/part0403p01_01.crf','part_order_no=PO20190215-0148');</label></td>
						</tr>
						<tr>
							<td><label>부품발주서(영문)</label></td>
							<td><label>part/part0403p01_02.crf</label></td>
							<td><label>part_order_no=PO20190215-0148</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('part/part0403p01_02.crf','part_order_no=PO20190215-0148');">부품발주서(영문)</button></td>
							<td><label>openReportPanel('part/part0403p01_02.crf','part_order_no=PO20190215-0148');</label></td>
						</tr>
						<tr>
							<td colspan="4"><label>서비스</label></td>
						</tr>
						<tr>
							<td><label>정비지시서</label></td>
							<td><label>serv/serv0101p01_01.crf</label></td>
							<td><label>s_job_report_no=20200728-003</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('serv/serv0101p01_01.crf','s_job_report_no=20200728-003');">정비지시서</button></td>
							<td><label>openReportPanel('serv/serv0101p01_01.crf','s_job_report_no=20200728-003');</label></td>
						</tr>
						<tr>
							<td><label>정비지시서>부품견적서</label></td>
							<td><label>serv/serv0101p01_02.crf</label></td>
							<td><label>s_job_report_no=20200728-003</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('serv/serv0101p01_02.crf','s_job_report_no=20200728-003');">부품견적서</button></td>
							<td><label>openReportPanel('serv/serv0101p01_02.crf','s_job_report_no=20200728-003');</label></td>
						</tr>
						<tr>
							<td><label>정비지시서>정비견적서</label></td>
							<td><label>serv/serv0101p01_03.crf</label></td>
							<td><label>s_job_report_no=20200728-003</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('serv/serv0101p01_03.crf','s_job_report_no=20200728-003');">정비견적서</button></td>
							<td><label>openReportPanel('serv/serv0101p01_03.crf','s_job_report_no=20200728-003');</label></td>
						</tr>
						<tr>
							<td><label>정비지시서>거래명세표</label></td>
							<td><label>serv/serv0101p01_04.crf</label></td>
							<td><label>s_job_report_no=20200728-003</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('serv/serv0101p01_04.crf','s_job_report_no=20200728-003');">거래명세표</button></td>
							<td><label>openReportPanel('serv/serv0101p01_04.crf','s_job_report_no=20200728-003');</label></td>
						</tr>
						<tr>
							<td><label>정비지시서>점검체크리스트</label></td>
							<td><label>serv/serv0101p16_01.crf</label></td>
							<td><label>s_job_report_no=20200729-001</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('serv/serv0101p16_01.crf','s_job_report_no=20200729-001');">점검체크리스트</button></td>
							<td><label>openReportPanel('serv/serv0101p16_01.crf','s_job_report_no=20200729-001');</label></td>
						</tr>
						<tr>
							<td><label>서비스일지</label></td>
							<td><label>serv/serv0102p01_01.crf</label></td>
							<td><label>s_as_no=20200730-0001</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('serv/serv0102p01_01.crf','s_as_no=20200730-0001');">서비스일지</button></td>
							<td><label>openReportPanel('serv/serv0102p01_01.crf','s_as_no=20200730-0001');</label></td>
						</tr>
						<tr>
							<td colspan="4"><label>회계</label></td>
						</tr>
						<tr>
							<td><label>경조금신청서</label></td>
							<td><label>acnt/acnt0601p01_01.crf</label></td>
							<td><label>s_mem_no=MB00001093</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('acnt/acnt0601p01_01.crf','s_mem_no=MB00001093');">경조금신청서</button></td>
							<td><label>openReportPanel('acnt/acnt0601p01_01.crf','s_mem_no=MB00001093');</label></td>
						</tr>
						<tr>
							<td><label>경력증명서</label></td>
							<td><label>acnt/acnt0601p01_02.crf</label></td>
							<td><label>s_mem_no=MB00001093</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('acnt/acnt0601p01_02.crf','s_mem_no=MB00001093');">경력증명서</button></td>
							<td><label>openReportPanel('acnt/acnt0601p01_02.crf','s_mem_no=MB00001093'');</label></td>
						</tr>
						<tr>
							<td><label>재직증명서</label></td>
							<td><label>acnt/acnt0601p01_03.crf</label></td>
							<td><label>s_mem_no=MB00001093</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('acnt/acnt0601p01_03.crf','s_mem_no=MB00001093');">재직증명서</button></td>
							<td><label>openReportPanel('acnt/acnt0601p01_03.crf','s_mem_no=MB00001093');</label></td>
						</tr>
						<tr>
							<td><label>세금계산서</label></td>
							<td><label>acnt/acnt0301p01_01.crf</label></td>
							<!-- <td><label>taxbill_no=TB20200915-0001</label></td> -->
							<td><label>inout_doc_no=IN20200915-009</label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('acnt/acnt0301p01_01.crf','inout_doc_no=IN20200915-009');">세금계산서</button></td>
							<td><label>openReportPanel('acnt/acnt0301p01_01.crf','inout_doc_no=IN20200915-009');</label></td>
						</tr>
						<tr>
							<td colspan="4"><label>렌탈</label></td>
						</tr>
						<tr>
							<td><label>임대차계약서</label></td>
							<td><label>rent/rent0101p01_01.crf</label></td>
							<td><label></label></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanel('rent/rent0101p01_01.crf','rental_doc_no=RT20200807-003');">임대차계약서</button></td>
							<td><label>openReportPanel('rent/rent0101p01_01.crf','rental_doc_no=RT20200807-003');</label></td>
						</tr>
						<!-- <tr>
							<td><label>동적</label></td>
							<td><input type="text" placeholder="/sample/test.crf" id="report_path" style="width: 95%;"/></td>
							<td><input type="text" placeholder="/sample/test?test_seq=123" id="data_url" style="width: 95%;"/></td>
							<td><button type="button" class="btn btn-info" onclick="openReportPanelDynamic();">동적리포트</button></td>
							<td><label></label></td>
						</tr> -->
					</tbody>
				</table>
			</div>
		</div>
	</div>
</body>
</html>
