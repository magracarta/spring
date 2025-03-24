<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 자산 > 휴가원관리 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-20 11:30:57
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var ynList = [ {"code_value":"Y", "code_name" : "Y"}, {"code_value" :"N", "code_name" :"N"}];
		
		$(document).ready(function() {
			createAUIGrid();
			goInitSearch();
			goSearch();
		});
		
		// 초기화면 화면 검색
		function goInitSearch() {
			$M.setValue("s_holiday_year", $M.getCurrentDate("yyyy"));
		}
		
		function goSearch() {
	
			var param = {
				"s_year" 			: $M.getValue("s_holiday_year"),
				"s_org_code" 		: $M.getValue("s_org_code"),
				"s_kor_name" 		: $M.getValue("s_kor_name"),
				"s_retire_yn" 		: $M.getValue("s_retire_yn"),
				"s_sort_key" 		: "a.path_org_code, a.kor_name",
				"s_sort_method" 	: "asc"	
			};
			
			
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						console.log("result : ", result);
						$("#total_cnt").html(result.total_cnt);
						$M.setValue("s_year", param.s_holiday_year);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			);
		}
		
		function goNew() {
			var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=950, height=670, left=0, top=0";
			
			$M.goNextPage("/acnt/acnt0602p01", "", {popupStatus : popupOption});
		}
		
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				height : 550,
				showRowNumColumn: true,
				fillColumnSizeMode : false,
				editable : true
			};
			var columnLayout = [
				{
					dataField : "holiday_year",
					visible : false
				}, 
				{
					dataField : "mem_no",
					visible : false
				},
				{    
					headerText : "부서", 
					dataField : "org_name", 
					width : "110", 
					minWidth : "45",
					style : "aui-center",
					editable : false
				},
				{    
					headerText : "직원명", 
					dataField : "kor_name", 
					width : "100", 
					minWidth : "45",
					style : "aui-center aui-popup",
					editable : false
				},
				{    
					headerText : "입사일자", 
					dataField : "ipsa_dt", 
					width : "100", 
					minWidth : "45",
					style : "aui-center",
					editable : false,
					dataType : "date",
					formatString : "yy-mm-dd"
				},
				{    
					headerText : "사번", 
					dataField : "emp_id", 
					width : "100", 
					minWidth : "45",
					style : "aui-center",
					editable : false
				},
				{    
					headerText : "연간<br>일수",
					dataField : "issue_cnt", 
					width : "55", 
					minWidth : "35",
					style : "aui-center aui-editable",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == 0) {
							return "";
						} else {
						    return AUIGrid.formatNumber(value, "#,##0");
						}
					},
				},
				{    
					headerText : "사용<br>일수", 
					dataField : "use_day_cnt", 
					width : "55", 
					minWidth : "35",
					style : "aui-center",
					editable : false,
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == 0) {
							return "";
						} else {
						    return AUIGrid.formatNumber(value, "#,##0");
						}
					},
				},
				{    
					headerText : "잉여<br>일수", 
					dataField : "unuse_day_cnt", 
					width : "55", 
					minWidth : "35",
					style : "aui-center",
					editable : false,
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == 0) {
							return "";
						} else {
						    return AUIGrid.formatNumber(value, "#,##0");
						}
					},
				},
				{
					headerText : "국내출장",
					children : [ 
						{
							headerText : "건수", 
							dataField : "in_biz_trip_cnt", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
						{    
							headerText : "일수", 
							dataField : "in_biz_trip_day", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
					]
				},
				{
					headerText : "국외출장",
					children : [ 
						{
							headerText : "건수", 
							dataField : "over_biz_trip_cnt", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
						{    
							headerText : "일수", 
							dataField : "over_biz_trip_day", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
					]
				},
				{
					headerText : "종일휴가",
					children : [ 
						{
							headerText : "건수", 
							dataField : "all_vacation_cnt", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
						{    
							headerText : "일수", 
							dataField : "all_vacation_day", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
					]
				},
				{
					headerText : "오전휴가",
					children : [ 
						{
							headerText : "건수", 
							dataField : "am_vacation_cnt", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
						{    
							headerText : "일수", 
							dataField : "am_vacation_day", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
					]
				},
				{
					headerText : "오후휴가",
					children : [ 
						{
							headerText : "건수", 
							dataField : "pm_vacation_cnt", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
						{    
							headerText : "일수", 
							dataField : "pm_vacation_day", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
					]
				},
				{
					headerText : "공가",
					children : [ 
						{
							headerText : "건수", 
							dataField : "official_vacation_cnt", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
						{    
							headerText : "일수", 
							dataField : "official_vacation_day", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
					]
				},
				{
					headerText : "특별휴가",
					children : [ 
						{
							headerText : "건수", 
							dataField : "spc_vacation_cnt", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
						{    
							headerText : "일수", 
							dataField : "spc_vacation_day", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
					]
				},
				{
					headerText : "무급휴가",
					children : [ 
						{
							headerText : "건수", 
							dataField : "unpaid_vacation_cnt", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
						{    
							headerText : "일수", 
							dataField : "unpaid_vacation_day", 
							width : "40", 
							minWidth : "35",
							style : "aui-center",
							editable : false,
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								if (value == 0) {
									return "";
								} else {
								    return AUIGrid.formatNumber(value, "#,##0");
								}
							},
						},
					]
				},
				{    
					headerText : "미결<br>신청일수", 
					dataField : "ing_day_cnt",
					width : "60", 
					minWidth : "45",
					style : "aui-center",
					editable : false,
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == 0) {
							return "";
						} else {
						    return AUIGrid.formatNumber(value, "#,##0");
						}
					},
				},
				{
					headerText : "쪽지<br/>발송",
					dataField : "paper_cnt",
					width : "70",
					minWidth : "50",
					style : "aui-center aui-popup",
					editable : false,
				},
			];
			
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "kor_name") {
					console.log(event.item.holiday_year);
					var holiday_year = $M.nvl(event.item.issue_cnt, 0);
					if(holiday_year < 1) {
						alert("연차 정보가 없습니다.");
						return;
					};
					var param = {
						"s_mem_no" 	: event.item.mem_no,
						// "s_year" 	: event.item.holiday_year,
						"s_year" 	: $M.getValue("s_holiday_year"),
					};
					var popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1350, height=520, left=0, top=0";
					$M.goNextPage("/acnt/acnt0602p02", $M.toGetParam(param), {popupStatus : popupOption});
				} else if (event.dataField == "paper_cnt") {
					var param = {
						s_mem_no : event.item.mem_no,
						s_year: event.item.holiday_year
					}
					
					var popupOption = "";
					
					$M.goNextPage("/acnt/acnt0602p03", $M.toGetParam(param) , {popupStatus : popupOption});
				}
			});
		}
		
		function enter(fieldObj) {
			var field = ["s_kor_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		//엑셀다운로드
		function fnDownloadExcel() {
			var year = $M.getValue("s_year");
			fnExportExcel(auiGrid, year + "년 휴가원 목록", "");
		}

		// Q&A [14310] : 연차 발급
		function fnAnnaulCreate() {
			$M.goNextPageAjax('/mmyy/mmyy0106p01/sync', {}, {method : 'POST'},
					function(result) {
						if(result.success) {
							alert("등록이 완료되었습니다.");
							goSearch();
						}
					}
			);
		}
		
		// 수정
		function goModify() {
			var changeGridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역
			if (changeGridData.length == 0) {
				alert("변경내역이 없습니다.");
				return;
			}
			
			var holidayYearArr = [];
			var memNoArr = [];
			var issueCntArr = []; // 연간일수
			var holidayAttendYn = []; // 연차 출석 적용 여부
			
			for (var i = 0; i < changeGridData.length; i++) {
				holidayYearArr.push(changeGridData[i].holiday_year);
				memNoArr.push(changeGridData[i].mem_no);
				issueCntArr.push(changeGridData[i].issue_cnt);
				holidayAttendYn.push(changeGridData[i].holiday_attend_yn);
			}
			
			var option = {
					isEmpty : true
			};
			
			var param = {
					holiday_year_str : $M.getArrStr(holidayYearArr, option),
					mem_no_str : $M.getArrStr(memNoArr, option),
					issue_cnt_str : $M.getArrStr(issueCntArr, option),
					holiday_attend_yn_str : $M.getArrStr(holidayAttendYn, option),
			}
			
			$M.goNextPageAjaxSave(this_page + "/modify", $M.toGetParam(param) , {method : 'POST'},
				function(result) {
		    		if(result.success) {
		    			goSearch();
					}
				}
			);	
		}
		
		// 휴가일수알림쪽지
		function fnIssueCntAlarmSendPaper() {
			var yyyy = $M.getCurrentDate('yyyy');
			var param = {
				send_dt: yyyy + '0701',
				duplicate_send_yn: 'Y'
			}
			$M.goNextPageAjaxMsg("휴가일수알림쪽지 쪽지를 발송 하시겠습니까?\n*" + yyyy + "년07월01일 기준으로 발송됩니다.","/bat/paper/issueCntAlarm", $M.toGetParam(param) , {method : 'GET'},
				function(result) {
					if(result.success) {
						alert("발송이 완료 되었습니다.");
						goSearch();
					}
				}
			);
		}

		// 임의지정통보쪽지
		function fnIssueCntForcedUseSendPaper() {
			var yyyy = $M.getCurrentDate('yyyy');
			var param = {
				send_dt: yyyy + '0701',
				loop_date_size: '3',
			}
			$M.goNextPageAjaxMsg("임의지정통보쪽지 쪽지를 발송하시겠습니까?","/bat/paper/issueCntForcedUse", $M.toGetParam(param) , {method : 'GET'},
				function(result) {
					if(result.success) {
						alert("발송이 완료 되었습니다.");
						goSearch();
					}
				}
			);
		}

		function show9() {
			document.getElementById("show9").style.display="block";
		}
		function hide9() {
			document.getElementById("show9").style.display="none";
		}
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<input type="hidden" id="s_year" name="s_year">
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
									<col width="60px">
									<col width="120px">								
									<col width="45px">
									<col width="120px">
									<col width="55px">
									<col width="120px">
									<col width="110px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th>조회년도</th>
										<td>
											<select class="form-control" id="s_holiday_year" name="s_holiday_year">
												<c:forEach var="i" begin="${inputParam.s_current_year - 5}" end="${inputParam.s_current_year + 5}" step="1">
													<option value="${i}" <c:if test="${i==inputParam.s_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</td>
										<th>부서</th>
										<td>
											<select id="s_org_code" name="s_org_code" class="form-control">
												<option value="">- 전체 -</option>
												<c:forEach items="${list}" var="item">
												  <option value="${item.org_code}">${item.org_name}</option>
												</c:forEach>
											</select>
										</td>
										<th>직원명</th>
										<td>
											<input type="text" class="form-control" name="s_kor_name" id="s_kor_name">
										</td>
										<td class="pl10">
											<div class="form-check form-check-inline">
												<input type="checkbox" id="s_retire_yn" name="s_retire_yn" checked="checked" value="Y"/>
												<label for="s_retire_yn">퇴사자제외</label>
											</div>
										</td>
										<td>
											<button type="button" onclick="javascript:goSearch();" class="btn btn-important" style="width: 50px;">조회</button>
										</td>									
									</tr>						
								</tbody>
							</table>					
						</div>
						<!-- /검색영역 -->
						<!-- 조회결과 -->
						<div class="title-wrap mt10">
							<h4>조회결과</h4>
							<i class="material-iconserror font-16" style="vertical-align: middle;" onmouseover="javascript:show9()" onmouseout="javascript:hide9()"></i>
							<div class="con-info" id="show9" style="max-height: 500px; left: 7%; width: 460px; display: none; top:3%;">
								<ul class="">
									<li>
										<span style="font-weight: bold">재직 1년 미만</span><br>
										1개월 만근하면, 연차 1일 발생
									</li>
									<li>
										<span style="font-weight: bold">재직 1년 이상</span><br>
										전년도 출근율 80% 이상이면, 연차 15일 발생 (연차 공식 : 15/12*전년도 근무월수)<br>
										전년도 출근율 80% 미만이면, 전년도 개근한 개월 수 만큼 연차 발생(가산휴가X)
									</li>
									<li>
										<span style="font-weight: bold">+3년 이상 재직 시(가산휴가)</span><br>
										매 2년마다 1일씩 늘어나요(최대 25일까지)
									</li>
								</ul>
							</div>
							<div class="btn-group">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
						</div>
						<!-- /조회결과 -->
						<div id="auiGrid"></div>
						<div class="btn-group mt5">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
							</div>	
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
							</div>	
						</div>				
					</div>
				</div>		
			</div>
			<!-- /contents 전체 영역 -->	
		</div>		
	</form>
</body>
</html>