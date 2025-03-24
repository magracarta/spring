<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 정산 > 중고장비재고현황 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-06-18 16:45:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				showFooter : true,
				footerPosition : "top",
				headerHeight : 60,
				enableMovingColumn : false					
			};
			var columnLayout = [
				{
					headerText : "관리번호", 
					dataField : "display_no", 
					width : "70",
					minWidth : "65",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
	                  var ret = "";
	                  if (value != null && value != "") {
	                     ret = value.split("-");
	                     ret = ret[0]+"-"+ret[1];
	                     ret = ret.substr(4, ret.length);
	                  }
	                   return ret; 
	               }, 
				},
				{
					headerText : "관리번호", 
					dataField : "machine_used_no", 
					visible: false
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "90",
					minWidth : "65",
					style : "aui-left"
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "160",
					minWidth : "110",
					style : "aui-center"
				},
				{ 
					headerText : "전차주명", 
					dataField : "old_cust_name", 
					width : "65",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "관리처", 
					dataField : "mng_org_name", 
					width : "80",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "매입일", 
					dataField : "taxbill_dt", 
					width : "65",
					minWidth : "65",
					dataType : "date",  
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{ 
					headerText : "매입가", 
					dataField : "used_price", 
					width : "100",
					minWidth : "65",
					dataType : "numeric",
					style : "aui-right"
				},
				{ 
					headerText : "품의가", 
					dataField : "agent_price", 
					width : "100",
					minWidth : "65",
					dataType : "numeric",
					style : "aui-right"				
				},
				{ 
					headerText : "판매일", 
					dataField : "sale_dt", 
					width : "65",
					minWidth : "65",
					dataType : "date",  
					formatString : "yy-mm-dd",
					style : "aui-center"
				},		
				{ 
					headerText : "판매전<br\>처리구분<br\>상태", 
					dataField : "not_sale_buy_status_name", 
					width : "65",
					minWidth : "65",
					style : "aui-center"
				},
				{ 
					headerText : "관리사항", 
					dataField : "desc_text",
					width : "420",
					minWidth : "30",
					style : "aui-left"
				}
			];
			// 푸터레이아웃
			var footerColumnLayout = [ 
				{
					labelText : "합계",
					positionField : "taxbill_dt",
					style : "aui-center aui-footer",
				}, 
				{
					dataField : "used_price",
					positionField : "used_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}, 
				{
					dataField : "agent_price",
					positionField : "agent_price",
					operation : "SUM",
					formatString : "#,##0",
					style : "aui-right aui-footer"
				}
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 푸터 객체 세팅
			AUIGrid.setFooter(auiGrid, footerColumnLayout);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "display_no" ) {
					var params = {
							"machine_used_no" : event.item.machine_used_no 
					};
					
					var popupOption = "";
					$M.goNextPage('/acnt/acnt0408p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});	
		}
		
		// 전체 선택/취소
		function fnChangeGubunAll() {
			if($M.getValue("s_gubun_all_yn") == "Y") {
				var param = {s_gubun_all_yn : "Y",s_gubun_purchase_yn : "Y",s_gubun_consignment_yn : "Y",s_gubun_rental_yn : "Y",s_gubun_salecomplete_yn : "Y"}
				$M.setValue(param);
			} else {
				var param = {s_gubun_all_yn : "",s_gubun_purchase_yn : "",s_gubun_consignment_yn : "",s_gubun_rental_yn : "",s_gubun_salecomplete_yn : ""}
				$M.setValue(param);
			}
		}
		
		// 구분변경
		function fnChangeGubun() {
			var s_gubun_all_yn = $M.getValue("s_gubun_all_yn");
			var s_gubun_purchase_yn = $M.getValue("s_gubun_purchase_yn");			//본사매입
			var s_gubun_consignment_yn = $M.getValue("s_gubun_consignment_yn");		//확정위탁
			var s_gubun_rental_yn = $M.getValue("s_gubun_rental_yn"); 				//렌탈장비
			var s_gubun_salecomplete_yn = $M.getValue("s_gubun_salecomplete_yn");	//판매완결

			if(s_gubun_purchase_yn == "Y" && s_gubun_consignment_yn == "Y" && s_gubun_rental_yn == "Y" && s_gubun_salecomplete_yn == "Y") {
				$M.setValue("s_gubun_all_yn", "Y");
			} else {
				$M.setValue("s_gubun_all_yn", "");
			}

		}	
		
		
		function goSearch() {

			var param = {
				s_standard_dt : $M.getValue("s_standard_dt"), 						// 기준일
				s_gubun_purchase_yn : $M.getValue("s_gubun_purchase_yn"), 			// 본사매입
				s_gubun_consignment_yn : $M.getValue("s_gubun_consignment_yn"), 	// 확정위탁
				s_gubun_rental_yn : $M.getValue("s_gubun_rental_yn"), 				// 렌탈장비
				s_gubun_salecomplete_yn : $M.getValue("s_gubun_salecomplete_yn"), 	// 판매완결
				s_sort_key : "machine_used_no",
				s_sort_method : "asc nulls last"
			}
			
			if( $M.getValue("s_gubun_purchase_yn") 		== "" &&
				$M.getValue("s_gubun_consignment_yn") 	== "" &&
				$M.getValue("s_gubun_rental_yn") 		== "" &&
				$M.getValue("s_gubun_salecomplete_yn") 	== "" 	 ) {
				
				alert("처리상태를 한개이상 선택해주세요");
				return;
				
			}
			
			
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						$("#total_cnt").html(result.list.length);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			); 
		}
		
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "중고장비재고현황", exportProps);
		}
			
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">			
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>
								<col width="65px">
								<col width="140px">
								<col width="65px">
								<col width="400px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>기준일자</th>
									<td>
										<div class="input-group width120px">
											<input type="text" class="form-control border-right-0 calDate" id="s_standard_dt" name="s_standard_dt" dateformat="yyyy-MM-dd" alt="" value="${inputParam.s_current_dt}">
										</div>
									</td>
									<td >
										<div class="form-check form-check-inline">
											처리상태
										</div>
									</td>
									<td >
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_gubun_all_yn" name="s_gubun_all_yn" value="Y" onclick="javascript:fnChangeGubunAll()">
											<label class="form-check-label">전체</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" checked="checked" id="s_gubun_purchase_yn" name="s_gubun_purchase_yn" value="Y"  onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_purchase_yn" >본사매입</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" checked="checked"  id="s_gubun_consignment_yn" name="s_gubun_consignment_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_consignment_yn" >확정위탁</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_gubun_rental_yn" name="s_gubun_rental_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_rental_yn" >렌탈장비</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="checkbox" id="s_gubun_salecomplete_yn" name="s_gubun_salecomplete_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_salecomplete_yn" >판매완결</label>
										</div>
									</td>											
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch();" >조회</button>
									</td>																									
								</tr>														
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary"  id="total_cnt" >0</strong>건
						</div>	
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>		
					</div>				
				</div>
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>