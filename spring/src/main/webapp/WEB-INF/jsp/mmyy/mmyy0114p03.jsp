<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무접수현황 > 렌탈가능장비리스트
-- 작성자 : 박동훈
-- 최초 작성일 : 2024-12-06
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		var searchMngOrgCode = null;
	
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
			goSearch();
		});
		
		// 펼침
		function fnChangeColumn(event) {
			var data = AUIGrid.getGridData(auiGrid);
			var target = event.target || event.srcElement;
			if(!target)	return;

			var dataField = target.value;
			var checked = target.checked;
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];

				if(checked) {
					AUIGrid.showColumnByDataField(auiGrid, dataField);
				} else {
					AUIGrid.hideColumnByDataField(auiGrid, dataField);
				}
			}
			
 		    // 구해진 칼럼 사이즈를 적용 시킴.
			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
		}
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				enableFilter :true,
			};
			var columnLayout = [
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "55", 
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "65", 
					minWidth : "45",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "차대번호", 
					dataField : "body_no", 
					width : "130", 
					minWidth : "120",
					style : "aui-center aui-popup",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "연식", 
					dataField : "made_dt", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value.substr(0, 4);
					},
					width : "45", 
					minWidth : "35",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "가동시간", 
					dataField : "op_hour", 
					width : "55", 
					minWidth : "35",
					dataType : "numeric",
					formatString : "#,##0",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "GPS", 
					headerStyle : "aui-fold",
					dataField : "gps_no", 
					width : "100", 
					minWidth : "100",
					style : "aui-center aui-popup",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (item.sar != null && item.sar != "") {
							ret = "SA-R";
						}
						return ret;
					},
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "번호판번호",
					headerStyle : "aui-fold",
					dataField : "mreg_no", 
					width : "90", 
					minWidth : "35",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "관리센터", 
					dataField : "mng_org_name",
					width : "55", 
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "소유센터",
					dataField : "own_org_name",
					width : "55",
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "65", 
					minWidth : "50", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",
					width : "100", 
					minWidth : "100", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "상태", 
					dataField : "rental_status_name", 
					style : "aui-center aui-popup",
					width : "60", 
					minWidth : "50",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == null || value == "") {
							return "렌탈가능";
						} else {
							return value;
						}
					},
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "접수자",
					headerStyle : "aui-fold",
					dataField : "receipt_mem_name",
					width : "50", 
					minWidth : "50", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈금액", 
					headerStyle : "aui-fold",
					dataField : "rental_amt",
					width : "70",  
					minWidth : "70",  
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (value == 0) {
							return "";
						}
						return $M.setComma(ret);
					},
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈시작", 
					dataField : "rental_st_dt",
					dataType : "date",   
					formatString : "yy-mm-dd",
					width : "63", 
					minWidth : "50", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈종료", 
					dataField : "rental_ed_dt",
					dataType : "date",   
					formatString : "yy-mm-dd",
					width : "63", 
					minWidth : "50", 
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{ 
					headerText : "렌탈기간", 
					dataField : "day_cnt",
					width : "63", 
					minWidth : "50", 
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return value != null && value != "" ? value+"일" : "";
					},
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "장비상세",
					dataField : "remark",
					minWidth : "100",
					width : "110",
					style : "aui-left",
				},
				{
					dataField : "rental_status_cd",
					visible : false
				},
				{
					dataField : "rental_machine_no",
					visible : false
				},
				{
					dataField : "rental_doc_no",
					visible : false
				},
				{
					dataField : "sar",
					visible : false
				},
				{
					dataField : "gps_seq",
					visible : false
				},
				{
					dataField : "mng_org_code",
					visible : false
				},
				{
					dataField : "own_org_code",
					visible : false
				},
				{
					dataField : "extend_yn",
					visible : false
				},
				{
					dataField : "job_report_no",
					visible : false
				}
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			
			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//차대번호셀 선택한 경우 
				if(event.dataField == "body_no") {
					var params = {
						rental_machine_no : event.item.rental_machine_no
					};
					var popupOption = "scrollbars=no, resizable=yes, menubar=yes, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=500, left=0, top=0";
					$M.goNextPage('/rent/rent0201p01', $M.toGetParam(params), {popupStatus : popupOption});
				}
				
				//GPS셀 선택한 경우
				if(event.dataField == "gps_no") {
					if (event.item.gps_seq != "") {
						window.open('http://s1.u-vis.com');
					}
					if (event.item.sar != "") {
						window.open('https://terra.smartassist.yanmar.com/machine-operation/map');
					}
				}
				
				//상태셀 선택한 겨우
				if(event.dataField == "rental_status_name" ) {
					var status = event.item.rental_status_cd;					
					if(status =="" || status == "05") {
						// 센터일 경우 본인 센터 조회된 상태로 시작(2020-11-10), 다른센터것도 조회할수있지만, 신청은 불가
						<c:if test="${page.fnc.F06046_001 eq 'Y'}">
							if (event.item.mng_org_code != "${SecureUser.org_code}") {
								alert("타 센터 장비를 렌탈신청할 수 없습니다.");
								return false;
							}
						</c:if>
						var params = {
							rental_machine_no : event.item.rental_machine_no,
							"s_self_assign_no" : "${inputParam.s_self_assign_no}",
							"s_cust_no" : "${inputParam.s_cust_no}"
						}
						var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";
						$M.goNextPage("/rent/rent010101", $M.toGetParam(params), {popupStatus : popupOption});
						// window.close();
						$("#popup-bg-loading").show();
					}
				}
			});	
			
			// 펼치기 전에 접힐 컬럼 목록
			var auiColList = AUIGrid.getColumnInfoList(auiGrid);
			for (var i = 0; i <auiColList.length; ++i) {
				if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
					dataFieldName.push(auiColList[i].dataField);
				}
			}
			
			for (var i = 0; i < dataFieldName.length; ++i) {
				var dataField = dataFieldName[i];
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}
			
			// 구해진 칼럼 사이즈를 적용 시킴.
			var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    AUIGrid.setColumnSizeList(auiGrid, colSizeList);
			
			
		}
		
		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_body_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		function fnMyExecFuncName(data) {
	        goSearch();
	    }
		
		function fnMyExecModelFuncName(data) {
			$M.setValue("s_machine_plant_seq", data.machine_plant_seq);
	        goSearch();
		}
		
		function goSearch() {
			var param = {
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_machine_plant_seq : $M.getValue("s_machine_plant_seq"),
				s_body_no : $M.getValue("s_body_no"),
				s_cust_no : $M.getValue("s_cust_no"),
				s_mng_org_code : $M.getValue("s_mng_org_code"),
				s_own_org_code : $M.getValue("s_own_org_code"),
				s_made_dt : $M.getValue("s_made_dt"),
				s_rental_status_cd : "05",
				s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				s_sort_key : "maker_cd, vm.machine_name",
				s_sort_method : "asc"
			};


			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
						$(".maker_list").remove();
						if(result.makerList != null) {
							var str = "";
							for(var i = 0; i < result.makerList.length; i++) {
								var item = result.makerList[i];
								str += "<span class=\"maker_list font-16\" style=\"margin-left: 10px; margin-right: 10px; font-family: \"NG';\"> | </span><a href=\"javascript:fnChangeMaker('"+item.maker_cd+"', '"+ i +"');\" class=\"maker_list allmaker maker"+ i +" font-16\" style=\"font-family: 'NG';\">" + item.maker_name + "</a>";
							}
						}
						$(".contents-wrap").append(str);
						console.log(result.makerList);
						searchMngOrgCode = param.s_mng_org_code;

						$(".allmaker").css("font-weight", "normal");
						$(".maker0").css("font-weight", "bold");
					};
				}
			);
		}
		
		function fnDownloadExcel() {
			  var exportProps = {};
			  fnExportExcel(auiGrid, "렌탈신청현황", exportProps);
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
	<!-- 기본 -->					
				<div class="search-wrap">				
						<table class="table">
							<colgroup>							
								<col width="50px">
								<col width="80px">
								<col width="40px">
								<col width="140px">
								<col width="60px">
								<col width="90px">
								<col width="50px">
								<col width="280px">
								<col width="60px">
								<col width="75px">
								<col width="60px">
								<col width="75px">
								<col width="40px">
								<col width="80px">
								<col width="40px">
								<col width="80px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>메이커</th>
									<td>
										<select id="s_maker_cd" name="s_maker_cd" class="form-control">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th>모델</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-12">
												<div class="input-group">
													<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
														<jsp:param name="s_sale_yn" value="N"/>
							                     		<jsp:param name="required_field" value="s_machine_name"/>
							                     	</jsp:include>	
												</div>
											</div>
										</div>
									</td>									
									<th>차대번호</th>
									<td>
										<input type="text" class="form-control" name="s_body_no">
									</td>
									<th>고객명</th>
									<td>
										<jsp:include page="/WEB-INF/jsp/common/searchCust.jsp">
				                     		<jsp:param name="required_field" value=""/>
			 	                     		<jsp:param name="focusInFuncName" value=""/>
			 	                     		<jsp:param name="focusInClearYn" value="Y"/>
				                     	</jsp:include>
									</td>
									<th>관리센터</th>
									<td>
										<select class="form-control" name="s_mng_org_code">
											<option value="">- 전체 -</option>
											<c:forEach items="${orgCenterList}" var="item">
												<option value="${item.org_code}"
												<c:if test="${SecureUser.org_type eq 'CENTER' && SecureUser.org_code eq item.org_code}">selected</c:if>
												>${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>소유센터</th>
									<td>
										<select class="form-control" name="s_own_org_code">
											<option value="">- 전체 -</option>
											<c:forEach items="${orgCenterList}" var="item">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>연식</th>
									<td>
										<select class="form-control" id="s_made_dt" name="s_made_dt">
											<option value="">- 전체 -</option>
											<option value="2">2년이하</option>
											<option value="3~4">3~4년식</option>
											<option value="5~6">5~6년식</option>
											<option value="7">7년 이상</option>
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch()" >조회</button>
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
							<div class="right">
								<div class="form-check form-check-inline">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</c:if>	
								<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>								
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>						
					</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>
						<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>