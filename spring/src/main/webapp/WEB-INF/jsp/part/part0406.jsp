<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 발주/납기관리 > 미출하부품현황-장비 지급품 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		$(document).ready(function() {
			// 그리드 생성
			createAUIGrid();
			fnInit();
			fnChangeType();
		});
		
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		
		function fnInit() {
			/* var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3)); */
		}
		
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
			/* var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
		    AUIGrid.setColumnSizeList(auiGrid, colSizeList); */
		}
		
		function fnChangeType() {
			if ($M.getValue("s_search_type") == "") {
				$(".typeAll").addClass("dpn");
			} else {
				$(".typeAll").removeClass("dpn");
			}
		}
		
		// 그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				editable : false,
				showSelectionBorder : false
			};
			// AUIGrid 칼럼 설정
			var columnLayout = [
				{
				    headerText: "관리번호",
				    dataField: "machine_doc_no",
				    width : "65",
				    minWidth : "55",
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
					headerText : "출하자",
					headerStyle : "aui-fold",
					dataField : "out_mem_name",
					width : "65",
				    minWidth : "55",
					style : "aui-center"
				},
				{
				    headerText: "출하일",
				    dataField: "out_dt",
				    dataType : "date",   
				    width : "65",
				    minWidth : "55",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{
				    headerText: "고객명",
				    width : "65",
				    minWidth : "55",
				    dataField: "fake_cust_name",
					style : "aui-center"
				},
				{
				    headerText: "휴대폰",
				    headerStyle : "aui-fold",
				    dataField: "fake_hp_no",
				    width : "100",
				    minWidth : "100",
					style : "aui-center"
				},
				{
				    headerText: "모델명",
				    dataField: "machine_name",
				    width : "105",
				    minWidth : "55",
					style : "aui-center"
				},
				{
				    headerText: "차대번호",
				    headerStyle : "aui-fold",
				    dataField: "body_no",
				    width : "150",
				    minWidth : "100",
					style : "aui-center"
				},
				{
				    headerText: "부품번호",
				    dataField: "part_no",
				    width : "100",
				    minWidth : "95",
					style : "aui-center"
				},
				{
				    headerText: "부품명",
				    dataField: "part_name",
				    width : "130",
				    minWidth : "120",
					style : "aui-left"
				},
				{
				    headerText: "미출고",
				    dataField: "no_out_qty",
					style : "aui-right",
					width : "55",
				    minWidth : "55",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						return value === 0 ? "" : value;
					}
				},
				{
				    headerText: "출고일자",
				    headerStyle : "aui-fold",
				    dataField: "part_out_dt",
				    dataType : "date",   
				    width : "65",
				    minWidth : "55",
					formatString : "yy-mm-dd",
					style : "aui-center"
				},
				{
				    headerText: "처리자",
				    headerStyle : "aui-fold",
				    dataField: "part_out_mem_name",
				    width : "65",
				    minWidth : "55",
					style : "aui-center"
				},
				{
				    headerText: "임의처리사유",
				    headerStyle : "aui-fold",
				    dataField: "desc_text",
				    width : "130",
				    minWidth : "55",
					style : "aui-left"
				},
				{
					headerText : "출고구분",
					dataField : "gubun",
					width : "120",
				    minWidth : "120",
					editable : false, // 그리드의 에디팅 사용 안함( 템플릿에서 만든 Select 로 에디팅 처리 하기 위함 )
					 renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer",
					},  
					// dataField 로 정의된 필드 값이 HTML 이라면 labelFunction 으로 처리할 필요 없음.
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var template = '<div>';
						template += '<span>';
						template += '<button type="button" style="width : 45%" class="aui-grid-button-renderer" value="in_btn" onclick="javascript:goFakeProcPopup('+rowIndex+');">임의처리</button>';
						template += '<button type="button" style="width : 45%; margin-left : 5%" class="aui-grid-button-renderer" value="bl_btn" onclick="javascript:goAddOutPopup('+rowIndex+');">';
						if (item.free_yn == 'Y') {
							template += '무상출고</button>';
						} else {
							template += '유상출고</button>';
						}
						template += '</span>';
						template += '</div>';
						return template;
					}
				}, 
				{
					dataField : "seq_no",
					visible : false
				},
				{
					dataField : "option_yn",
					visible : false
				},
				{
					dataField : "machine_out_doc_seq",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					dataField : "opt_code",
					visible : false
				},
				{
					dataField : "cust_name",
					visible : false
				},
				{
					dataField : "hp_no",
					visible : false
				},
				{
					dataField : "free_yn",
					visible : false
				}
			];
	
			// 그리드 출력
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			// AUIGrid.setFixedColumnCount(auiGrid, 6);
			// 클릭 시 팝업페이지 호출
 			AUIGrid.bind(auiGrid, "cellClick", function(event) {
 				if(event.dataField == "machine_doc_no") {
 					var params = {
 						machine_doc_no 	: event.item.machine_doc_no
 					};
					var popupOption = "scrollbars=yes, resizable=yes, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1300, height=800, left=0, top=0";
					$M.goNextPage('/sale/sale0101p03', $M.toGetParam(params), {popupStatus : popupOption}); 
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
		}
		
		function goSearch() {
			var param = {};
			if ($M.getValue("s_search_type") == "ALL") {
				if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
					return;
				}; 
				param["s_start_dt"] = $M.getValue("s_start_dt");
				param["s_end_dt"] = $M.getValue("s_end_dt");
				param["s_search_type"] = "ALL";
			}
			param["s_masking_yn"] = $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N";
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result){
					if(result.success) {
						$("#total_cnt").html(result.list.length);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			); 
		}
		
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "미출하부품현황-장비지급품", {})
		}

		function goFakeProcPopup(rowIndex) {
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
			if (item.no_out_qty === 0) {
				alert("미출고 내역이 없습니다.");
				return false;
			}
			var param = {
				machine_doc_no : item.machine_doc_no,
				machine_out_doc_seq : item.machine_out_doc_seq,
				machine_plant_seq : item.machine_plant_seq,
				seq_no : item.seq_no,
				part_no : item.part_no,
				no_out_qty : item.no_out_qty,
				cust_no : item.cust_no,
				cust_name : item.cust_name,
				hp_no : item.hp_no,
				opt_code : item.opt_code
			};
			$M.toGetParam(param);
			var msg = "임의로 출고처리 하시겠습니까?"
			if (item.option_yn == "Y") { // seq 없어서 메모등록불가 바로 등록함
				console.log("옵션");
				$M.goNextPageAjaxMsg(msg, this_page, $M.toGetParam(param), {method : 'POST'},
					function(result) {
						if(result.success) {
							goSearch();
						};
					}
				);
			} else {
				console.log("일반부품");
				// asis remark "출하품임의"+pyearid+pslipno+serialno+" :"+codeid+"("+qtyid0+"개)";
				var asisYearAndSlip = item.machine_doc_no.replace(/\D/g,'');
				asisYearAndSlip = asisYearAndSlip.substring(0, asisYearAndSlip.length - 2);
				
				param['remark'] = "출하품임의"+asisYearAndSlip+item.seq_no+" :"+item.part_no+"("+item.no_out_qty+"개)";	
				var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=100, height=100, left=0, top=0";
				$M.goNextPage("/part/part0406p01", $M.toGetParam(param), {popupStatus : poppupOption});	
			}
		}

		function goAddOutPopup(rowIndex) {
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
			if (item.no_out_qty === 0) {
				alert("미출고 내역이 없습니다.");
				return false;
			};
			var param = {
				machine_out_doc_seq : item.machine_out_doc_seq,
				type : item.free_yn == "Y" ? "AF" : "AP"
			}
			$M.goNextPageAjax("/sale/sale0101p08/checkCostOutPart", $M.toGetParam(param), {method: 'get', loader : false},
                    function (result) {
                         if (result.success) {
                        	if (result.type == "P") {
                        		alert("유상전표를 먼저 처리하세요.");
                        	} else {
                        		var poppupOption = "scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=850, left=0, top=0";
                                $M.goNextPage('/sale/sale0101p08', $M.toGetParam(param), {popupStatus : poppupOption});
                        	}
                         }
                    }
               );
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
								<col width="55px" class="typeAll">
								<col width="260px" class="typeAll">
								<col width="50px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th class="typeAll">출하일</th>
									<td class="typeAll">
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0  calDate" id="s_start_dt" 
														name="s_start_dt" dateformat="yyyy-MM-dd" alt="출하시작일" value="${searchDtMap.s_start_dt }">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0  calDate" id="s_end_dt" 
														name="s_end_dt" dateformat="yyyy-MM-dd" alt="출하종료일" value="${searchDtMap.s_end_dt }">
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
									<th>자료구분</th>
									<td>
										<select class="form-control" id="s_search_type" name="s_search_type" onchange="fnChangeType()">
											<option value="">미결</option>
											<option value="ALL">전체</option>
										</select>
									</td>								
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
						<h4>미출하부품현황</h4>
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
								<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
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