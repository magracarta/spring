<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 모니터/딜러 지급현황 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
		
		var machineGroupByMaker = ${machineGroupByMaker}
		var machineList = ${machineList}
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_dealer_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		function fnChangeMakerCd() {
			$('#s_machine_plant_seq').combogrid("reset");
			var makerCd = $M.getValue("s_maker_cd");
			var list = [];
			if (makerCd != "") {
				list = machineGroupByMaker[makerCd];
			} else {
				list = machineList;
			}
			$M.reloadComboData("s_machine_plant_seq", list);
		}
		
		function goSearch() {
			var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));
			
			$M.setValue("s_start_dt", startDt);
			$M.setValue("s_end_dt", endDt);
			
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {
				return;
			};
			
			var param = {
				"s_start_dt" : startDt+"01",
				"s_end_dt" : endDt+"31",
				"s_center_org_code" : $M.getValue("s_center_org_code"),
				"s_dealer_name" : $M.getValue("s_dealer_name"),
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_machine_plant_seq" : $M.getValue("s_machine_plant_seq"),
				"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				"s_sort_key" : "sale_dt",
				"s_sort_method" : "desc",
			};
	
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").text(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
        function fnSetDate(year, mon) {
        	if(mon.length == 1) {
        		mon = "0" + mon;
			}
        	var sYearMon = year + mon;

        	return $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');
		}
		
		function createAUIGrid() {
			var gridPros = {
				height : 555,
				showRowNumColumn: true,
			};
			var columnLayout = [
				{
					dataField : "machine_doc_no",
					visible : false
				},
				{
					headerText : "판매일", 
					dataField : "sale_dt", 
					width : "90",
					minWidth : "90",
					dataType : "date",
					formatString : "yy-mm-dd", 
					style : "aui-popup",
				},
				{
					headerText : "부서", 
					dataField : "center_org_name", 
					width : "100",
					minWidth : "100",
					style : "aui-center",
				},
				{
					headerText : "구분", 
					dataField : "cost_item_name", 
					width : "100",
					minWidth : "100",
					style : "aui-center",
				},
				{
					headerText : "모니터/딜러명", 
					dataField : "dealer_name", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
				},
				{
					headerText : "휴대폰", 
					dataField : "dealer_hp", 
					width : "110",
					minWidth : "110",
					style : "aui-center",
				},
				{
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "90",
					minWidth : "90",
					style : "aui-center",
				},
				{
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "55",
					minWidth : "55",
					style : "aui-center",
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "55",
					minWidth : "55",
					style : "aui-center",
				},
				{
					headerText : "출하일", 
					dataField : "out_dt", 
					width : "90",
					minWidth : "90",
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd", 
				},
				{
					headerText : "정산완료", 
					dataField : "cost_proc_dt", 
					width : "90",
					minWidth : "90",
					style : "aui-center",
					dataType : "date",
					formatString : "yy-mm-dd", 
				},
				{
					headerText : "정산금액", 
					dataField : "amt",
					width : "100",
					minWidth : "55",
					dataType : "numeric",
					style : "aui-center",
				},
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event){
				if(event.dataField == "sale_dt") {
					var param = {
						"machine_doc_no" : event.item["machine_doc_no"]
					};
					var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=925, left=0, top=0";
					$M.goNextPage('/sale/sale0101p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
		}
	
		// 엑셀 다운로드
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "모니터/딜러 지급현황", exportProps);
		}
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<input type="hidden" name="s_start_dt" alt="시작날짜">
<input type="hidden" name="s_end_dt" alt="종료날짜">
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
	<!-- 기본 -->					
				<div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="60px">
                                <col width="280px">
                                <col width="30px">
                                <col width="80px">
                                <col width="90px">
                                <col width="100px">
                                <col width="50px">
                                <col width="100px">
                                <col width="50px">
                                <col width="100px">
                                <col width="*">
                            </colgroup>
                            <tbody>
                                <tr>							
                                    <th>판매기간</th>	
                                    <td>
                                        <div class="form-row inline-pd widthfix">
                                            <div class="col width80px">
                                                <select class="form-control" id="s_start_year" name="s_start_year" alt="조회시작년">
					                                <c:forEach var="i" begin="1" end="22" varStatus="status">
					                                	<option value="${s_start_year-i+1}">${s_start_year-i+1}년</option>
					                                </c:forEach>
					                            </select>
                                            </div>
                                            <div class="col width50px">
                                                <select class="form-control" id="s_start_mon" name="s_start_mon" alt="조회시작월">
					                                <c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==s_start_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
					                            </select>
                                            </div>
                                            <div class="col width16px text-center">~</div>
                                            <div class="col width80px">
                                                <select class="form-control" id="s_end_year" name="s_end_year" alt="조회종료년">
					                                <c:forEach var="i" begin="1" end="22" varStatus="status">
					                                	<option value="${inputParam.s_current_year-i+1}">${inputParam.s_current_year-i+1}년</option>
					                                </c:forEach>
					                            </select>
                                            </div>
                                            <div class="col width50px">
                                                <select class="form-control" id="s_end_mon" name="s_end_mon" alt="조회종료월">
                                                    <c:forEach var="i" begin="1" end="12" step="1">
														<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==s_current_mon}">selected</c:if>>${i}월</option>
													</c:forEach>
                                                </select>
                                            </div>
                                        </div>
                                    </td>
                                    <th>부서</th>
                                    <td>
                                        <select class="form-control width100px" id="s_center_org_code" name="s_center_org_code">
											<option value="">- 전체 -</option>
											<c:forEach items="${orgCenterList}" var="item">
												<option value="${item.org_code}"
												<c:if test="${SecureUser.org_type eq 'CENTER' && SecureUser.org_code eq item.org_code}">selected</c:if>
												>${item.org_name}</option>
											</c:forEach>
										</select>
                                    </td>	
                                    <th>모니터/딜러명</th>
                                    <td>
                                        <input type="text" class="form-control" id="s_dealer_name" name="s_dealer_name">
                                    </td>
                                    <th>메이커</th>
                                    <td>
                                        <select id="s_maker_cd" name="s_maker_cd" class="form-control" onchange="fnChangeMakerCd()">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
                                    </td>		
                                    <th>모델명</th>
                                    <td>
                                        <input type="text" style="width : 140px";
											id="s_machine_plant_seq" 
											name="s_machine_plant_seq" 
											easyui="combogrid"
											header="N"
											easyuiname="machineName" 
											panelwidth="140"
											maxheight="300"
											textfield="machine_name"
											multi="N"
											enter="goSearch()"
											idfield="machine_plant_seq" />
                                    </td>                                    					
                                    <td class="">
                                        <button type="button" class="btn btn-important" style="width: 50px;" onclick="goSearch()">조회</button>
                                    </td>
                                </tr>							
                            </tbody>
                        </table>
                    </div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<div class="form-check form-check-inline">
									<label  class="form-check-input"  for="s_masking_yn"><input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >마스킹 적용</label>
								</div>
							</c:if>
							<span class="text-warning">※임의비용 "정산완료"만 조회됩니다.</span>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div id="auiGrid" style="margin-top: 5px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>