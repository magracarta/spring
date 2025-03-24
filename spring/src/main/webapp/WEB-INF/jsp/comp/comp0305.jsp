<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 고객연관팝업 > 고객연관팝업 > null > 견적서조회
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-12 15:46:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		<%-- 여기에 스크립트 넣어주세요. --%>
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});
		
		function enter(fieldObj) {
			if (fieldObj.name == "s_cust_name") {
				goSearch();
			}
		} 
		
		function fnInit() {
			var param = {
				s_start_dt : $M.addMonths($M.toDate("${inputParam.s_current_dt}"), -3),
				s_rfq_type_cd : "${inputParam.rfq_type}" != "MACHINE" ? "${inputParam.rfq_type}" : "MACHINE"
			};
			"${inputParam.type_select_yn}" != "Y" ? processDisabled(['s_rfq_type_cd'], true, null, null) : ""; 
			$M.setValue(param);
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				editable : false,
				rowIdField : "rfq_no",
				enableCellMerge : true,
// 				rowStyleFunction : function(rowIndex, item) {
// 					if($M.checkRangeByValue($M.getCurrentDate(), item.expire_dt) == false) { // 완료
// 						return "aui-status-complete";
// 					} else if(item.process_no != "") {
// 						return "aui-status-complete";
// 					}
// 				}
			};
			var columnLayout = [
				{
					dataField : "rfq_no",   
					visible : false
				},
				{
					headerText : "견적서번호", 
					dataField : "rfq_no_1", 
					width : "8%", 
					style : "aui-center",
					cellMerge : true
				},
				{
					headerText : "차수", 
					dataField : "rfq_no_2", 
					width : "3%", 
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value) {
						return value.replace(/(^0+)/, "");
					}
				},
				{ 
					headerText : "등록일시", // 견적일자에 시간 저장안해서 등록일시로 변경 
					dataField : "reg_date",
					dataType : "date",   
					width : "11%", 
					style : "aui-center",
					formatString : "yy-mm-dd HH:MM:ss",
				},
				{
					dataField : "rfq_type_cd", 
					visible : false
				},
				{
					headerText : "구분", 
					dataField : "rfq_type_name", 
					width : "4%", 
					style : "aui-center"
				},
				{ 
					headerText : "유효기간", 
					dataField : "expire_dt",
					dataType : "date",   
					width : "7%", 
					style : "aui-center",
					formatString : "yyyy-mm-dd",
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",   
					width : "8%", 
					style : "aui-center",
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",  
					width : "9%", 
					style : "aui-center"
				},
				{ 
					headerText : "이메일", 
					dataField : "email",  
					width : "10%", 
					style : "aui-center"
				},
				{ 
					headerText : "견적금액", 
					dataField : "rfq_amt",  
					dataType : "numeric",
					width : "7%",
					formatString : "#,##0",
					style : "aui-right",
				},
				{ 
					headerText : "할인금액", 
					dataField : "discount_amt",  
					dataType : "numeric",
					width : "7%",
					formatString : "#,##0",
					style : "aui-right",
					labelFunction : function(rowIndex, columnIndex, value) {
						var ret = "";
						if (value != null && value != "0") {
							ret = $M.setComma(value);
						} else {
							ret = "0";
						}
						return ret;
					}
				},	
				{
					headerText : "견적내역", 
					dataField : "rfq_contents", 
					width : "13%", 
					style : "aui-left"
				},
				{
					headerText : "부서", 
					dataField : "rfq_org_name", 
					width : "7%", 
					style : "aui-center"
				},
				{
					headerText : "견적자", 
					dataField : "rfq_mem_name", 
					width : "6%", 
					style : "aui-center"
				},
				{
					dataField : "process_no", 
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			// AUIGrid.setFixedColumnCount(auiGrid, 7);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if (event.dataField != "rfq_no_1") {
					// Row행 클릭 시 반영
					try{
						if($M.checkRangeByValue($M.getCurrentDate(), event.item.expire_dt) == false) {
							alert("유효기간이 경과했습니다.");
							return false;
						} else if(event.item.process_no != "") {
							alert("사용한 견적서는 재사용이 불가합니다. ");
							return false;
						}
						opener.${inputParam.parent_js_name}(event.item);
						fnClose();	
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
				}
			});
		}
		
		function goSearch() {
			if ($M.validation(document.main_form) == false) {
				return;
			};
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			}; 
			var param = {
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_cust_name : $M.getValue("s_cust_name"),
				s_rfq_type_cd : $M.getValue("s_rfq_type_cd"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				s_sort_key : "rfq_no desc, reg_date",
				s_sort_method : "desc",
				s_refer_yn : "Y"
			};
			if ("RENTAL" == $M.getValue("s_rfq_type_cd")) {
				param["s_rental_machine_no"] = "${inputParam.rental_machine_no}";
			}
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						console.log(result.list);
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
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
<!-- 폼테이블 -->					
			<div>	
			<c:if test="${inputParam.rfq_type eq 'PART'}">		
				<div class="btn-group">
					<div class="right">
						<div class="text-warning ml5" id="part_sale_rfq">
						※사용한 견적서는 재사용이 불가합니다. (재사용 필요시, 즐겨찾는 견적서로 등록후 사용)
						</div>
					</div>
					</div>
			</c:if>
<!-- 검색영역 -->					
				<div class="search-wrap mt5">
					<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="50px">
								<col width="100px">
								<col width="60px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>등록일</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" width="150" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="요청시작일">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate"  id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="요청종료일" value="${inputParam.s_current_dt}">
												</div>
											</div>
										</div>
									</td>									
									<th>고객명</th>
									<td>
										<div class="icon-btn-cancel-wrap">
											<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
										</div>
									</td>
									<th>구분</th>
									<td>
										<select class="form-control" id="s_rfq_type_cd" name="s_rfq_type_cd">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${codeMap['RFQ_TYPE']}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>
									</td>									
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
										&nbsp;&nbsp;
										<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
										<div class="form-check form-check-inline">
											<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
											<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
										</div>
										</c:if>												
									</td>
								</tr>								
							</tbody>
						</table>
				</div>
<!-- /검색영역 -->
				<div id="auiGrid" style="margin-top: 5px;height: 370px;"></div>
			</div>		
<!-- /폼테이블 -->
			<div class="btn-group mt10">
				<div class="left">
					 총 <strong class="text-primary" id="total_cnt">0</strong>건 
				</div>	
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>