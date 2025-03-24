<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 결재선관리 > 대리결재처리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-10-19 15:39:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var rowIndex;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
// 			fnInit();
		});
		
// 		function fnInit() {
// 			var now = "${inputParam.s_current_dt}";
// 			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
// 		}
		
		// 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				showRowNumColumn: true,
				enableSorting : true,
				rowIdField : "row_id", 
				rowIdTrustMode : true,
				showStateColumn : true,
				editable : true,
			};
			var columnLayout = [
				{ 
					headerText : "부서", 
					dataField : "org_name", 
					style : "aui-center",
					width : "120",
					minWidth : "120",
					editable : false,
				},
				{ 
					headerText : "결재 지정자", 
					dataField : "mem_name", 
					width : "100",
					minWidth : "100",
					style : "aui-center aui-popup",
					editable : false,
				},
				{ 
					headerText : "결재 대상자", 
					dataField : "cover_mem_name", 
					width : "100",
					minWidth : "100",
					style : "aui-center aui-popup",
					editable : false,
				},
				{ 
					dataField : "seq_no", 
					visible : false, 
				},
				{ 
					dataField : "row_id", 
					visible : false, 
				},
				{ 
					dataField : "org_code", 
					visible : false
				},
				{
					dataField : "mem_no",
					visible : false
				},
				{
					dataField : "cover_mem_no",
					visible : false
				},
				{
					dataField : "cover_org_code",
					visible : false
				},
				{
					headerText : "대결 시작일(From)", 
					dataField : "cover_st_dt", 
					dataType : "date",   
					width : "120",
					minWidth : "120",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					},
					editable : true
				},
				{
					headerText : "대결 종료일(To)", 
					dataField : "cover_ed_dt", 
					dataType : "date",   
					width : "120",
					minWidth : "120",
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					},
					editable : true
				},
				{ 
					headerText : "등록일", 
					dataField : "reg_date",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					width : "150",
					minWidth : "150",
					editable : false,
					style : "aui-center"
				},
				{ 
					headerText : "등록자", 
					dataField : "reg_mem_name",
					width : "100",
					minWidth : "100",
					editable : false,
					style : "aui-center"
				},
				{ 
					headerText : "사용여부", 
					dataField : "use_yn", 
					width : "80",
					minWidth : "80",
					style : "aui-center",
					renderer : {
						type : "CheckBoxEditRenderer",
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					}
				}
			];
			// 실제로 #grid_wrap 에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var frm = document.main_form;
				rowIndex = event.rowIndex;
				// 결재 지정자 클릭 시
				if(event.dataField == "mem_name") {
					var param = {
							's_mem_name' : event.item['mem_name']
					};
					openSearchMemberPanel('fnSetMemInfo', $M.toGetParam(param));
				// 결재 대상자 클릭 시
				} else if (event.dataField == "cover_mem_name") {
					if(event.item["mem_name"] == "") {
						alert("결재 지정자를 먼저 지정해주세요.");
						return false;
					}
					var param = {
							's_mem_name' : event.item['cover_mem_name']
					};
					openSearchMemberPanel('fnSetCoverMemInfo', $M.toGetParam(param));
				} 
				
				if(String(this.tagName).toUpperCase() == "INPUT") return;
				if(event.dataField == "use_yn") {
					if(event.value == "Y") {
						AUIGrid.setCellValue(event.pid, event.rowIndex, "use_yn", "N");
					} 
					if(event.value == "N") {
						AUIGrid.setCellValue(event.pid, event.rowIndex, "use_yn", "Y");
					}
				} 
			}); 
		}
		
		// 결재 대상자 팝업 데이터 세팅
		function fnSetMemInfo(data) {
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
			if(item.cover_org_code != "") {
				var orgCode = data.org_code;
				var coverOrgCode = item.cover_org_code;
				if(orgCode.substring(0, 1) != coverOrgCode.substring(0, 1)) {
					fnCheckCoverOrgCode();
					return false;
				}
			}
			AUIGrid.updateRow(auiGrid, { "mem_no" : data.mem_no }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "mem_name" : data.mem_name }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "org_name" : data.org_name }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "org_code" : data.org_code }, rowIndex);
		}
		
		// 결재 지정자 팝업 데이터 세팅
		function fnSetCoverMemInfo(data) {
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
			var orgCode = item.org_code;
			var coverOrgCode = data.org_code;
			
			if(orgCode.substring(0, 1) != coverOrgCode.substring(0, 1)) {
				fnCheckOrgCode();
				return false;
			}
			AUIGrid.updateRow(auiGrid, { "cover_mem_no" : data.mem_no }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "cover_mem_name" : data.mem_name }, rowIndex);
			AUIGrid.updateRow(auiGrid, { "cover_org_code" : data.org_code }, rowIndex);
		}
		
		// 그리드 빈값 체크
		function isValid() {
			return AUIGrid.validateGridData(auiGrid, ["org_name", "mem_name", "cover_mem_name", "cover_st_dt", "cover_ed_dt"], "필수 항목는 반드시 값을 입력해야 합니다.");
		}
		
		// 결재 부서 체크
		function fnCheckOrgCode() {
			return AUIGrid.showToastMessage(auiGrid, rowIndex, 2, "같은 부서 내에서만 지정 가능합니다.");
		}
		
		// 결재 부서 체크
		function fnCheckCoverOrgCode() {
			return AUIGrid.showToastMessage(auiGrid, rowIndex, 1, "같은 부서 내에서만 지정 가능합니다.");
		}
		
		//그리드 행추가
		function fnAdd() {
			var row = new Object();
			if(isValid()) {
				row.org_code = '';
				row.org_name = '';
				row.mem_name = '';
				row.mem_no = '';
				row.cover_mem_no = '';
				row.cover_mem_name = '';
				row.cover_org_code = '';
				row.cover_st_dt = "${inputParam.s_current_dt}";
				row.cover_ed_dt = '';
				row.use_yn = 'Y';
				AUIGrid.addRow(auiGrid, row, "last");

				var colIndex = AUIGrid.getColumnIndexByDataField(auiGrid, "mem_name");
				fnSetCellFocus(auiGrid, colIndex, "mem_name");
			}
		}

		
		function goSearch() {
			var param = {
				"s_start_dt" : $M.getValue("s_start_dt"),
				"s_end_dt" : $M.getValue("s_end_dt"),
				"s_org_code" : $M.getValue("s_org_code"),
				"s_mem_name" : $M.getValue("s_mem_name"),
				"s_cover_mem_name" : $M.getValue("s_cover_mem_name"),
				"s_sort_key" : "reg_date",
				"s_sort_method" : "desc"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		function enter(fieldObj) {
			var field = [ "s_mem_name", "s_cover_mem_name" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 저장
		function goSave() {
			if(isValid(auiGrid) === false) {
				return false;
			};
			if (fnChangeGridDataCnt(auiGrid) == 0){
				alert(msg.alert.data.noChanged);
				return false;
			};
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxSave(this_page + "/save", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.removeSoftRows(auiGrid);
						AUIGrid.resetUpdatedItems(auiGrid);
						goSearch();
					};
				}
			);
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGrid, "대리결재처리", exportProps);
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
								<col width="260px">								
								<col width="45px">
								<col width="100px">
								<col width="80px">
								<col width="120px">
								<col width="80px">
								<col width="120px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right">대결일자</th>
									<td>
										<div class="form-row inline-pd widthfix">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}" alt="출고 시작일">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_end_dt}" alt="출고 완료일">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
				                     		<jsp:param name="st_field_name" value="s_start_dt"/>
				                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
				                     		<jsp:param name="click_exec_yn" value="Y"/>
				                     		<jsp:param name="exec_func_name" value="goSearch();"/>
				                     		</jsp:include>	
										</div>
									</td>
									<th>부서</th>
									<td>
										<select class="form-control" id="s_org_code" name="s_org_code">
											<option value="">- 전체 -</option>
											<c:forEach var="item" items="${orgList}">
												<option value="${item.org_code}">${item.org_name}</option>
											</c:forEach>
										</select>
									</td>
									<th>결재 지정자</th>
									<td>
										<input type="text" class="form-control" id="s_mem_name" name="s_mem_name">
									</td>
									<th>결재 대상자</th>
									<td>
										<input type="text" class="form-control" id="s_cover_mem_name" name="s_cover_mem_name">
									</td>
									<!-- <th>사용구분</th>
									<td>
										<select class="form-control"  id="s_use_yn" name="s_use_yn">
											<option value="Y">사용</option>
											<option value="N">미사용</option>
										</select>
									</td> -->
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
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
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>				
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>