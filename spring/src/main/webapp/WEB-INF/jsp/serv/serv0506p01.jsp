<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<% pageContext.setAttribute("newLineChar", "\n"); %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스캠페인 > null > 캠페인 상세
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 13:26:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 첨부파일의 index 변수
		var fileIndex = 1;
		
		var auiGridLeft;
		var auiGridRight;
		var rightGridCnt = 0;

		
		$(document).ready(function () {
			fnInit();
			fnDetail();
		});
	
		function fnInit() {
			createAUIGridLeft();
			createAUIGridRight();
			
			var rightGridCnt = AUIGrid.getRowCount(auiGridRight);
			console.log(rightGridCnt);
			if(rightGridCnt < 1) {
				alert("캠페인에 장비가 없어 삭제되었습니다.");
				opener.destroyGrid();
				window.close();
			}
		}
	
		function goSearch() {
	
			if($M.checkRangeByFieldName("s_shipment_st_dt", "s_shipment_end_dt", true) == false) {				
				return;
			};
	
			var param = {
	 			"s_shipment_st_dt" 	: $M.getValue("s_shipment_st_dt"),
				"s_shipment_end_dt" : $M.getValue("s_shipment_end_dt"),
				"s_body_no_st" 		: $M.getValue("s_body_no_st"),
				"s_body_no_end" 	: $M.getValue("s_body_no_end"),
				"s_machine_name" 	: $M.getValue("s_machine_name")		
			};
	
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridLeft, result.list);
						//$("#total_cnt").html(result.total_cnt);
						$("#machineGrid_total_cnt").html(result.total_cnt);
					}
				}
			);
		}
		
		// 수정
		function goModify() {
			
			var frm = $M.toValueForm(document.main_form);

			if($M.validation(frm) == false) { 
				return;
			};
	
			if($M.validation(document.main_form, {field:["campaign_name", "campaign_st_dt", "campaign_end_dt", "content"]}) == false) {
				return;
			};
			
			var gridForm  = fnChangeGridDataToForm(auiGridRight, 'use_yn');
			
			$M.copyForm(gridForm, frm);
			$M.goNextPageAjaxModify(this_page + "/modify", gridForm , {method : "POST"},			
				function(result) {
					if(result.success) {
						location.reload();
					}
				}
			); 
		}
	
		function fnAddFile() {
			openFileUploadPanel('setFileInfo', 'upload_type=BBS&file_type=both&max_size=2048');
		}
		
		function setFileInfo(result) {
			
			var str = ''; 
			str += '<div class="table-attfile-item bbs_file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.bbs_file_div').append(str);
			fileIndex++;
		}	
	
		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".bbs_file_" + fileIndex).remove();
			} else {
				return false;
			}	
		}

		// 해당 장비의 차대번호 조회
		function goMachinePopup(setName) {
			
			var param = {
				"s_machine_name" 	: $M.getValue("s_machine_name"),
			};
			openSearchDeviceHisPanel(setName, $M.toGetParam(param));
		}
		
		
		//차대번호 세팅(시작)
		function fnSetVINSt(data) {
			$M.setValue("s_body_no_st", data.body_no);
		}
	
		//차대번호 세팅(끝)
		function fnSetVINEnd(data) {
			$M.setValue("s_body_no_end", data.body_no);
		}

		function fnAdd() {
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
			var data = AUIGrid.getGridData(auiGridRight); 
	
			// 행이 없을 때
			var rowCount = AUIGrid.getRowCount(auiGridRight);
	
			for(var i = 0, len = rows.length; i < len; i++) {
			    rows[i]["addRow"] = 1;
			}
			
			if(rows.length <= 0) {
				alert(msg.alert.data.noChecked);
				return;
			}
	
			for(var i = 0; i < data.length; i++) {
				for(var j = 0; j < rows.length; j++) {
					if(data[i].machine_seq == rows[j]["machine_seq"]){
						alert("차대번호 : " + data[i].body_no + "가 이미 존재합니다.");
						return false;
					}
				}
			}
	
			//AUIGrid.setCellValue(auiGridRight ,rows, "campaign_seq", 0 );
			
			// 얻은 행을 결재선 목록 그리드에 추가하기
			AUIGrid.addRow(auiGridRight, rows, "last");
	
			AUIGrid.removeCheckedRows(auiGridLeft);
	
			AUIGrid.removeSoftRows(auiGridLeft);
			
			AUIGrid.resetUpdatedItems(auiGridLeft);
		}
		
		// 캠페인 대상자 목록 check 목록 삭제
		function fnRemove() {
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridRight);
			if(rows.length <= 0) {
				alert(msg.alert.data.noChecked);
				return;
			};
			// 삭제하면  "이동" 이고, 삭제하지 않으면 "복사" 를 구현할 수 있음.
			AUIGrid.removeCheckedRows(auiGridRight);
		}
	
		//임의처리
		function goRandomProcess() {
	
			var checkedItems = AUIGrid.getCheckedRowItems(auiGridRight);
			
			
			if(checkedItems.length <= 0) {
				alert("선택된 데이터가 없습니다.");
				return;
			};

			for(var i=0; i < checkedItems.length; i++) {
				if(checkedItems[i].item.proc_ypn_nm == "임의처리") {
					alert((Number(checkedItems[i].rowIndex) + Number(1)) + "번째 장비는 이미 임의처리한 값입니다.");
					return;
				};
				AUIGrid.setCellValue(auiGridRight, checkedItems[i].rowIndex, "proc_mem_no", "${SecureUser.mem_no}");
			};

			var frm = fnCheckedGridDataToForm(auiGridRight);
			var msg = "임의처리를 하시겠습니까?";
			
			$M.goNextPageAjaxMsg(msg, this_page +"/randomProcess", frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						location.reload();
					};
				}
			);
			
		}
	
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGridRight, "서비스캠페인", exportProps);
		}
		
		
		// 캠페인 종결처리
		function goComplete() {
			
			var param = {
				"campaign_seq" : $M.getValue("campaign_seq")
			};
			
			var msg = "종결처리를 하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page +"/prcsnCmplt", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						location.reload();
					};
				}
			);
		}
		
		// 캠페인 종결처리 취소
		function goCompleteCancel() {
			
			var param = {
				"campaign_seq" : $M.getValue("campaign_seq")
			};
			
			var msg = "종결처리를 취소 하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page +"/prcsnCmpltN", $M.toGetParam(param), {method : 'POST'}, 
				function(result) {
					if(result.success) {
						location.reload();
					};
				}
			);
		}
	
		function fnClose() {
			window.close();
		}
	
		function createAUIGridLeft() {
			var gridPros = {
				// rowIdField 설정
				rowIdField: "machine_seq",
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : true
	
			};
	
			var columnLayout = [
				{
					headerText : "machine_seq",
					dataField : "machine_seq",
					visible : false
				},
	 			{
					headerText : "장비명",
					dataField : "machine_name"
				},
				{
					headerText : "차대번호",
					dataField : "body_no"
				},
				{
					headerText : "출하일",
					dataField  : "out_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd"
				}
			];

	
			// 실제로 #grid_wrap에 그리드 생성
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
		}
	
		
		function createAUIGridRight() {
			var gridPros = {
				rowIdField : "_$uid",
				// 체크박스 표시 설정
				showRowCheckColumn : true,			
				// 전체 체크박스 표시 설정
				showRowAllCheckBox : true,
				// 전체 선택 체크박스가 독립적인 역할을 할지 여부
				independentAllCheckBox : true,

				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				
				// 행 소프트 제거 모드 해제
				softRemoveRowMode : true,
				rowIdTrustMode : true,
				showRowNumColumn : true,
				// 엑스트라 라디오 버턴 disabled 함수
				// 이 함수는 렌더링 시 빈번히 호출됩니다. 무리한 DOM 작업 하지 마십시오. (성능에 영향을 미침)
				// rowCheckDisabledFunction 이 아래와 같이 간단한 로직이라면, 실제로 rowCheckableFunction 정의가 필요 없습니다.
				// rowCheckDisabledFunction 으로 비활성화된 라디오버턴은 체크 반응이 일어나지 않습니다.(rowCheckableFunction 불필요)
				rowCheckDisabledFunction : function(rowIndex, isChecked, item) {
					 if(AUIGrid.isAddedById(auiGridRight, item._$uid)) {
						return false; // false 반환하면 disabled 처리됨
					} else {
						return true;					
					}
				}
	
			};
	
			var columnLayout = [
				{
					headerText : "campaign_seq",
					dataField : "campaign_seq",
					visible : false
				},
				{
					headerText : "machine_seq",
					dataField : "machine_seq",
					visible : false
				},
				{
					headerText : "모델명",
					dataField  : "machine_name",
					width: "20%",
				},
				{
					headerText : "차대번호",
					dataField  : "body_no",
					width: "20%",
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width: "10%",
				},
				{
					headerText : "휴대폰",
					dataField : "hp_no",
					width : "15%",
				},
				{
					headerText : "센터",
					dataField : "center_org_name",
					width : "10%",
				},
				{
					headerText : "지역",
					dataField : "area_do",
					width : "10%",
				},
				{
					headerText : "담당자",
					dataField : "sale_mem_name",
					width : "10%",
				},
				{
					headerText : "구분",
					dataField : "proc_ypn_nm",
					width : "8%",
				},
				{
					headerText : "처리일자",
					dataField : "proc_date",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "10%",
				},
				{
					dataField : "proc_mem_no",
					visible : false
				},
				{
					headerText : "처리자",
					dataField : "proc_mem_name",
					width : "10%",
				},
				{
					headerText : "가동시간",
					dataField : "op_hour",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);								
							} else {
								AUIGrid.restoreSoftRows(auiGridRight, "selectedIndex"); 
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridRight, campaginListJson);
	
			// 전체 체크박스 클릭 이벤트 바인딩
			AUIGrid.bind(auiGridRight, "rowAllChkClick", function(event) {
				if(event.checked) {
					var uniqueValues = AUIGrid.getColumnDistinctValues(event.pid, "machine_seq");
					AUIGrid.setCheckedRowsByValue(event.pid, "machine_seq", uniqueValues);
					// AUIGrid.addUncheckedRowsByValue(event.pid, "addRow", 1);
				} else {
					AUIGrid.setCheckedRowsByValue(event.pid, "machine_seq", []);
				}
			});
			
			rightGridCnt = AUIGrid.getRowCount(auiGridRight);
				
		}
		
	
		//캠페인 상세 내용
		function fnDetail(){
	
	 		$M.setValue("campaign_name" , "${campaginDtlInfo.campaign_name}");		//캠패인명
			$M.setValue("campaign_st_dt", "${campaginDtlInfo.campaign_st_dt}");		//시작일
			$M.setValue("campaign_ed_dt", "${campaginDtlInfo.campaign_ed_dt}");		//종료일
			$M.setValue("content"		, "${campaginDtlInfo.content}");			//내용
			$M.setValue("campaign_seq"	, "${campaginDtlInfo.campaign_seq}");		//캠패인아이디
			$M.setValue("file_seq"		, "${campaginDtlInfo.file_seq}");			//파일번호
	
			//파일이 존재할 경우 업로드한 파일 조회
			if("${campaginDtlInfo.file_seq}" != ""){
				goFileSearch();
			};
	
		} 
	
	
		//조회
		function goFileSearch() { 
	
			var fileSeq = "${campaginDtlInfo.file_seq}";
			
			var param = {
					"s_file_seq" : fileSeq
			};
			
			$M.goNextPageAjax(this_page + "/fileSearchInfo", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						var filseInfo = JSON.stringify(result)
						//저장한 파일 조회하기
						var str = ''; 
						str += '<div class="table-attfile-item bbs_file_' + fileIndex + '" style="float:left; display:block;">';
						str += '<a href="javascript:fileDownload(' + result.list[0].file_seq+ ');" style="color: blue;">' + result.list[0].origin_file_name + '</a>&nbsp;';
						str += '<input type="hidden" name="file_seq" value="' + result.list[0].file_seq + '"/>';
						str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.list[0].file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
						str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
						str += '</div>';
						
						$(".bbs_file_div").append(str);
					};
				}
			);
		} 
	</script>
</head>
<body class="bg-white class">
	<form id="main_form" name="main_form">
		<!-- 팝업 -->
	    <div class="popup-wrap width-100per">
	<!-- 타이틀영역 -->
	        <div class="main-title">
				<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
	<!-- /타이틀영역 -->
	        <div class="content-wrap">
	        
				<div class="row">
					<div class="col-4">
	<!-- 캠페인명 -->				
						<div>
							<div class="title-wrap">
								<h4>${SecureUser.kor_name}</h4>				
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right essential-item">제목</th>
										<td>
											<input type="text" class="form-control" id="campaign_name" name="campaign_name">
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">기간</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width120px">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate" id="campaign_st_dt" name="campaign_st_dt" dateFormat="yyyy-MM-dd" value="${inputParam.s_end_dt}" alt="조회 시작일">
													</div>
												</div>
												<div class="col width16px">~</div>
												<div class="col width120px">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate" id="campaign_ed_dt" name="campaign_ed_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_end_dt}" alt="조회 완료일">
													</div>
												</div>
											</div>
										</td>
									</tr>
									<tr>
										<th class="text-right essential-item">내용</th>
										<td>
											<textarea class="form-control" id="content" name="content" style="height: 100px;"></textarea>
										</td>
									</tr>
									<tr>
										<th class="text-right">이미지첨부</th>
										<td>
<!-- 											<div class="pr width200px">	
												<div class="custom-file">
													<button type="button" class="btn btn-primary-gra mr10" name="file_add_btn" id="file_add_btn" onclick="javascript:fnAddFile();">파일찾기</button>
												</div>						
											</div> -->
											<div class="table-attfile bbs_file_div" style="width:100%;">
												<div class="table-attfile" style="float:left">
												<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
												&nbsp;&nbsp;
											</div>
										</div>
										</td>
									</tr>																			
								</tbody>
							</table>
						</div>
	<!-- /캠페인명 -->		
	<!-- 대상자선별 -->				
						<div>
							<div class="title-wrap mt10">
								<h4>대상자선별</h4>				
							</div>
							<table class="table-border mt5">
								<colgroup>
									<col width="100px">
									<col width="">
								</colgroup>
								<tbody>
									<tr>
										<th class="text-right">장비명</th>
										<td>
											<div class="form-row">
												<div class="col-4">
													<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
							                     		<jsp:param name="required_field" value="s_machine_name"/>
							                     		<jsp:param name="s_maker_cd" value=""/>
							                     		<jsp:param name="s_machine_type_cd" value=""/>
							                     		<jsp:param name="s_sale_yn" value=""/>
							                     		<jsp:param name="readonly_field" value=""/>
							                     	</jsp:include>
						                     	</div>
					                     	</div>
										</td>
									</tr>
									<tr>
										<th class="text-right">차대번호</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col-4">
													<div class="input-group">
														<input type="text" id="s_body_no_st" name="s_body_no_st" class="form-control border-right-0 width120px" placeholder="시작">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goMachinePopup('fnSetVINSt');"><i class="material-iconssearch"></i></button>
													</div>
												</div>
												<div class="col-auto">~</div>
												<div class="col-4">
													<div class="input-group">
														<input type="text" id="s_body_no_end" name="s_body_no_end" class="form-control border-right-0" placeholder="끝">
														<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goMachinePopup('fnSetVINEnd');"><i class="material-iconssearch"></i></button>
													</div>
												</div>
											</div>
										</td>
									</tr>	
									<tr>
										<th class="text-right">출하일자</th>
										<td>
											<div class="form-row inline-pd widthfix">
												<div class="col width120px">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate" id="s_shipment_st_dt" name="s_shipment_st_dt" dateFormat="yyyy-MM-dd"  <%-- value="${inputParam.s_end_dt}" --%> alt="조회 완료일">
													</div>
												</div>
												<div class="col width16px">~</div>
												<div class="col width120px">
													<div class="input-group">
														<input type="text" class="form-control border-right-0 calDate" id="s_shipment_ed_dt" name="s_shipment_ed_dt" dateFormat="yyyy-MM-dd"  <%-- value="${inputParam.s_end_dt}" --%> alt="조회 완료일">
													</div>
												</div>
												<div class="col width60px">
													<button type="button" class="btn btn-important" style="width: 100%;" onclick="javascript:goSearch();">조회</button>
												</div>
											</div>
										</td>
									</tr>																	
								</tbody>
							</table>
						</div>
	<!-- /대상자선별 -->
	<!-- 조회결과 -->				
						<div>
							<div class="title-wrap mt10">
								<h4>조회결과</h4>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
							</div>
							<div id="auiGridLeft" style="margin-top: 5px; height: 100px;"></div>
						</div>
	<!-- /조회결과 -->							
					</div>
					<div class="col-8">
	<!-- 대상자목록 -->				
						<div>
							<div class="title-wrap">
								<h4>대상자 목록</h4>	
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
							</div>
							<div id="auiGridRight" style="margin-top: 5px; height: 520px;"></div>
						</div>
	<!-- /대상자목록 -->							
					</div>
				</div>
				<div class="btn-group mt10">
					<div class="left">
					총 <strong class="text-primary" id="machineGrid_total_cnt">0</strong>건
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goCompleteCancel();">종결취소</button>				</div>	
				</div>
	        </div>
	    </div>
	<!-- /팝업 -->
		<input type="hidden" id="file_seq" name="file_seq" value=""/>
		<input type="hidden" id="campaign_seq" name="campaign_seq" value=""/>
	</form>
</body>
</html>