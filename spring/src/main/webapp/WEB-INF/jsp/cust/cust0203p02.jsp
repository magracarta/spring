<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 부품판매 > 입출금전표처리 > null > 매출자료참조
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});
		
		function fnInit() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3));
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "inout_doc_no",
				showRowNumColumn: true,
			};
			var columnLayout = [
				{
					headerText : "번호", 
					dataField : "inout_doc_no", 
					width : "11%", 
					style : "aui-center"
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "inout_type_cd",
					visible : false
				},
				{ 
					headerText : "거래구분", 
					dataField : "inout_type_name", 
					width : "5%", 
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "업체명", 
					dataField : "breg_name", 
					width : "12%", 
					style : "aui-center",
				},
				{ 
					headerText : "적요", 
					dataField : "dis_desc_text", 
					style : "aui-left",
				},
				{ 
					headerText : "금액", 
					dataField : "total_amt", 
					dataType : "numeric",
					formatString : "#,##0",
					width : "9%", 
					style : "aui-right"
				},
				{ 
					headerText : "처리자", 
					dataField : "reg_mem_name", 
					width : "7%", 
					style : "aui-center"
				},
				{ 
					headerText : "비고", 
					dataField : "dis_remark",
					width : "17%", 
					style : "aui-left"
				},
				{ 
					headerText : "전표구분", 
					dataField : "inout_doc_type_name",
					width : "7%", 
					style : "aui-center"
				},
				{ 
					dataField : "inout_doc_type_cd",
					visible : false
				},
				{ 
					dataField : "part_sale_no",
					visible : false
				},
				{ 
					dataField : "job_report_no",
					visible : false
				},
				{ 
					dataField : "rental_doc_no",
					visible : false
				},
				{ 
					dataField : "machine_used_no",
					visible : false
				},
				{ 
					dataField : "rental_machine_no",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				opener.${inputParam.parent_js_name}(event.item);
				fnClose();
			});
		}
		   
		//조회
		function goSearch() { 
			var param = {
					"s_sort_key" : "inout_doc_no", 
					"s_sort_method" : "desc",
					"s_inout_doc_type_cd" : $M.getValue("s_inout_doc_type_cd"),
					"s_start_dt" : $M.getValue("s_start_dt"),
					"s_end_dt" : $M.getValue("s_end_dt")
			};

			if(${not empty inputParam.s_cust_no}) {
				param.s_cust_no = '${inputParam.s_cust_no}';
			}

			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		} 
		
		// 닫기
		function fnClose() {
			window.close();
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap">	 
			<div class="title-wrap">
				<h4>매출자료참조</h4>
			</div>
<!-- 검색조건 -->
			<div class="search-wrap mt5">
				<table class="table">
					<colgroup>
						<col width="65px">
						<col width="260px">
						<col width="50px">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>조회일자</th>
							<td>
								<div class="form-row inline-pd widthfix">
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일" value="">
										</div>
									</div>
									<div class="col-auto">~</div>
									<div class="col-5">
										<div class="input-group">
											<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_current_dt}">
										</div>
									</div>
								</div>							
							</td>
							<th>전표구분</th>
							<td>
								<select class="form-control" id="s_inout_doc_type_cd" name="s_inout_doc_type_cd">
									<option value="">- 전체 -</option>
									<c:forEach items="${codeMap['INOUT_DOC_TYPE']}" var="item">
									<c:if test="${item.code_value eq '05' || item.code_value eq '07' || item.code_value eq '11' || item.code_value eq '12' || item.code_value eq '13'}"><option value="${item.code_value}"></c:if>${item.code_name}</option>
									</c:forEach>
								</select>				
							</td>
							<td class="text-left"><button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button></td>
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
			<div class="title-wrap mt10">
				<h4>매출발생내역</h4>
			</div>
<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; height: 280px;"></div>
			<div class="btn-group mt5">
				<div class="left">
					총 <strong class="text-primary" id="total_cnt">0</strong>건
				</div>
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>